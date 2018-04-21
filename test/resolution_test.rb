require 'test_helper'

class ResolutionTest < Minitest::Test
  def test_it_can_resolve_empty_tree
    resolution = Galette::Resolution.new([], []).resolve
    assert_equal [], resolution
  end

  def test_single_version_no_requirements
    specification = Galette::Specification.new('rack') do |s|
      s.version '1.0.0'
    end
    resolution = Galette::Resolution.new([specification], []).resolve

    assert_equal [], resolution
  end

  def test_single_version_any_requirement
    specification = Galette::Specification.new('rack') do |s|
      s.version '1.0'
    end
    requirement = specification.requirement_semver
    resolution = Galette::Resolution.new([specification], [requirement]).resolve

    assert_equal 1, resolution.length
    assert_equal '1.0', resolution[0].version
    assert_equal 'rack', resolution[0].specification.name
  end

  def test_multiple_version_any_requirement
    specification = Galette::Specification.new('rack') do |s|
      s.version '2.0'
      s.version '1.0'
    end
    requirement = specification.requirement_semver
    resolution = Galette::Resolution.new([specification], [requirement]).resolve

    assert_equal 1, resolution.length
    assert_equal '2.0', resolution[0].version
    assert_equal 'rack', resolution[0].specification.name
  end

  def test_single_version_exact_requirement
    specification = Galette::Specification.new('rack') do |s|
      s.version '1.0'
    end
    requirement = specification.requirement_semver('1.0')
    resolution = Galette::Resolution.new([specification], [requirement]).resolve

    assert_equal 1, resolution.length
    assert_equal '1.0', resolution[0].version
    assert_equal 'rack', resolution[0].specification.name
  end

  def test_multiple_version_exact_requirement
    specification = Galette::Specification.new('rack') do |s|
      s.version '2.0'
      s.version '1.0'
      s.version '0.1'
    end
    requirement = specification.requirement_semver('1.0')
    resolution = Galette::Resolution.new([specification], [requirement]).resolve

    assert_equal 1, resolution.length
    assert_equal '1.0', resolution[0].version
    assert_equal 'rack', resolution[0].specification.name
  end

  def test_multiple_version_multiple_gems
    rack = Galette::Specification.new('rack') do |s|
      s.version '2.0'
      s.version '1.1'
      s.version '1.0'
    end
    rails = Galette::Specification.new('rails') do |s|
      s.version '2.0', requirements: [rack.requirement_semver('~> 1.0')]
      s.version '1.0', requirements: [rack.requirement_semver('~> 1.0')]
    end
    requirement = rails.requirement_semver
    resolution = Galette::Resolution.new([rails, rack], [requirement]).resolve

    assert_equal 2, resolution.length
    assert_equal '2.0', resolution[0].version
    assert_equal 'rails', resolution[0].specification.name
    assert_equal '1.1', resolution[1].version
    assert_equal 'rack', resolution[1].specification.name
  end

  def test_multiple_version_multiple_gems_reversed
    rack = Galette::Specification.new('rack') do |s|
      s.version '2.0'
      s.version '1.1'
      s.version '1.0'
    end
    rails = Galette::Specification.new('rails') do |s|
      s.version '2.0', requirements: [rack.requirement_semver('~> 1.0')]
      s.version '1.0', requirements: [rack.requirement_semver('~> 1.0')]
    end
    requirement = rails.requirement_semver
    resolution = Galette::Resolution.new([rack, rails], [requirement]).resolve

    assert_equal 2, resolution.length
    assert_equal '1.1', resolution[0].version
    assert_equal 'rack', resolution[0].specification.name
    assert_equal '2.0', resolution[1].version
    assert_equal 'rails', resolution[1].specification.name
  end

  # Example borrowed from Natalie Weizenbaum's article on PubGrub
  # https://medium.com/@nex3/pubgrub-2fb6470504f
  def test_example_from_pubgrub_article
    icons = Galette::Specification.new('icons') do |s|
      s.version '2.0.0'
      s.version '1.0.0'
    end
    dropdown = Galette::Specification.new('dropdown') do |s|
      3.downto(0).each do |i|
        s.version "2.#{i}.0", requirements: [icons.requirement_semver('~> 2.0')]
      end
      s.version '1.8.0', requirements: [icons.requirement_semver('~> 1.0')]
    end
    menu = Galette::Specification.new('menu') do |s|
      5.downto(1).each do |i|
        s.version "1.#{i}.0", requirements: [dropdown.requirement_semver('~> 2.0')]
      end
      s.version '1.0.0'
    end
    requirements = [
      menu.requirement_semver,
      icons.requirement_semver('< 2')
    ]
    resolution = Galette::Resolution.new([icons, dropdown, menu], requirements).resolve
  end
end
