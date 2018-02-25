require 'test_helper'

class AvailabilityTest < Minitest::Test
  def setup
    @spec = Galette::Specification.new('rack') do |s|
      s.version '3'
      s.version '2'
      s.version '1'
    end
  end

  def test_no_availability
    availability = Galette::Availability.none(@spec)

    assert_equal 0, availability.bitmap

    assert availability.none?
    refute availability.one?
    refute availability.multiple?

    assert_raises do
      availability.version
    end
  end

  def test_single_availability
    availability = Galette::Availability.new(@spec, 2)

    refute availability.none?
    assert availability.one?
    refute availability.multiple?

    assert_equal [@spec.versions[1]], availability.versions
    assert_equal "3", availability.version.version
  end

  def test_multiple_availability
    availability = Galette::Availability.new(@spec, 6)

    refute availability.none?
    refute availability.one?
    assert availability.multiple?

    assert_equal [@spec.versions[1], @spec.versions[2]], availability.versions

    assert_raises do
      availability.version
    end
  end

  def test_unneeded
    availability = Galette::Availability.new(@spec, 1)

    refute availability.none?
    assert availability.one?
    refute availability.multiple?

    assert_equal 1, availability.versions.length
    assert availability.version.unneeded?
  end

  def test_union
    a1 = Galette::Availability.new(@spec, 3)
    a2 = Galette::Availability.new(@spec, 6)

    combined = a1 | a2

    assert_equal @spec, combined.specification
    assert_equal 7, combined.bitmap

    assert_equal @spec.versions[0..2], combined.versions
  end

  def test_intersection
    a1 = Galette::Availability.new(@spec, 3)
    a2 = Galette::Availability.new(@spec, 6)

    combined = a1 & a2

    assert_equal @spec, combined.specification
    assert_equal 2, combined.bitmap

    assert_equal @spec.versions[1], combined.version
  end
end
