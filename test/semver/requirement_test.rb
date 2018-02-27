require 'test_helper'

class SemverRequirementTest < Minitest::Test
  def setup
    @spec = Galette::Specification.new('rack') do |s|
      s.version '2.1'
      s.version '2.0'
      s.version '1.1'
      s.version '1.0'
    end
  end

  def test_simple_equality
    requirement = Galette::Semver::Requirement.new(@spec, "2.0")
    assert_equal 0b00100, requirement.bitmap
  end

  def test_explicit_equality
    requirement = Galette::Semver::Requirement.new(@spec, "= 2.0")
    assert_equal 0b00100, requirement.bitmap
  end

  def test_nonexistant_equality
    requirement = Galette::Semver::Requirement.new(@spec, "= 6.6.6")
    assert_equal 0b00000, requirement.bitmap
  end

  def test_semver_squiggly
    requirement = Galette::Semver::Requirement.new(@spec, "~> 2.0")
    assert_equal 0b00110, requirement.bitmap
  end

  def test_lt
    requirement = Galette::Semver::Requirement.new(@spec, "< 2.0")
    assert_equal 0b11000, requirement.bitmap
  end

  def test_lte
    requirement = Galette::Semver::Requirement.new(@spec, "<= 2.0")
    assert_equal 0b11100, requirement.bitmap
  end

  def test_gt
    requirement = Galette::Semver::Requirement.new(@spec, "> 2.0")
    assert_equal 0b00010, requirement.bitmap
  end

  def test_gte
    requirement = Galette::Semver::Requirement.new(@spec, ">= 2.0")
    assert_equal 0b00110, requirement.bitmap
  end

  def test_availability
    requirement = Galette::Semver::Requirement.new(@spec, "2.0")
    availability = requirement.availability

    assert_equal 0b00100, availability.bitmap
    assert_equal @spec, availability.specification
  end
end
