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

    assert_equal 0b0000, availability.bitmap

    assert availability.none?
    refute availability.one?
    refute availability.multiple?

    assert_raises RuntimeError do
      availability.version
    end
  end

  def test_single_availability
    availability = Galette::Availability.new(@spec, 0b0010)

    refute availability.none?
    assert availability.one?
    refute availability.multiple?

    assert_equal [@spec.versions[1]], availability.versions
    assert_equal "3", availability.version.version
    refute availability.includes_unneeded?
  end

  def test_multiple_availability
    availability = Galette::Availability.new(@spec, 0b0110)

    refute availability.none?
    refute availability.one?
    assert availability.multiple?

    assert_equal [@spec.versions[1], @spec.versions[2]], availability.versions

    assert_raises RuntimeError do
      availability.version
    end
  end

  def test_unneeded
    availability = Galette::Availability.new(@spec, 0b0001)

    refute availability.none?
    assert availability.one?
    refute availability.multiple?

    assert_equal 1, availability.versions.length
    assert availability.version.unneeded?
    assert availability.includes_unneeded?
  end

  def test_union
    a1 = Galette::Availability.new(@spec, 0b0011)
    a2 = Galette::Availability.new(@spec, 0b0110)

    combined = a1 | a2

    assert_equal @spec, combined.specification
    assert_equal 0b0111, combined.bitmap

    assert_equal @spec.versions[0..2], combined.versions
  end

  def test_intersection
    a1 = Galette::Availability.new(@spec, 0b0011)
    a2 = Galette::Availability.new(@spec, 0b0110)

    combined = a1 & a2

    assert_equal @spec, combined.specification
    assert_equal 0b0010, combined.bitmap

    assert_equal @spec.versions[1], combined.version
  end

  def test_equality
    assert_equal(
      Galette::Availability.new(@spec, 0b0011),
      Galette::Availability.new(@spec, 0b0011)
    )

    refute_equal(
      Galette::Availability.new(@spec, 0b0011),
      Galette::Availability.new(@spec, 0b0010)
    )

    spec1 = @spec
    spec2 = @spec.dup
    refute_equal(
      Galette::Availability.new(spec1, 0b0011),
      Galette::Availability.new(spec2, 0b0011)
    )
  end
end
