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
end
