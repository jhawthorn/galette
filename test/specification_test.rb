require 'test_helper'

class SpecificationTest < Minitest::Test
  def test_requirement_semver_exact
    specification = Galette::Specification.new('rack') do |s|
      s.version '1.0.0'
    end
    availability = specification.requirement_semver('1.0.0')
    assert availability.one?
    assert_equal "1.0.0", availability.version.version
    assert_equal specification, availability.version.specification
  end

  def test_requirement_semver_unmatched
    specification = Galette::Specification.new('rack') do |s|
      s.version '1.0.0'
    end
    availability = specification.requirement_semver('6.6.6')

    refute_nil availability
    assert availability.none?
  end
end
