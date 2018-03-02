require 'test_helper'

class AvailabilitySetTest < Minitest::Test
  def setup
    @a = Galette::Specification.new('a') do |s|
      s.version '3'
      s.version '2'
      s.version '1'
    end
    @b = Galette::Specification.new('b') do |s|
      s.version '0.3'
      s.version '0.2'
      s.version '0.1'
    end
  end

  def test_empty
    availability = Galette::AvailabilitySet.new

    assert_equal({}, availability.to_h)
    assert_equal [], availability.specifications
    assert availability.valid?
  end

  def test_initialize_with_array
    availability = Galette::AvailabilitySet.new([
      Galette::Availability.new(@a, 0b0101),
      Galette::Availability.new(@b, 0b1010)
    ])

    assert_equal({
      @a => 0b0101,
      @b => 0b1010
    }.compare_by_identity, availability.to_h)
    assert_equal [@a, @b], availability.specifications
    assert availability.valid?
  end

  def test_intersect_same_spec
    lhs = Galette::AvailabilitySet.new([Galette::Availability.new(@a, 0b1101)])
    rhs = Galette::AvailabilitySet.new([Galette::Availability.new(@a, 0b1110)])

    combined = lhs & rhs

    assert_equal [@a], combined.specifications
    assert_equal 0b1100, combined.for(@a).bitmap
    assert combined.valid?
  end

  def test_intersect_different_specs
    lhs = Galette::AvailabilitySet.new([Galette::Availability.new(@a, 0b1101)])
    rhs = Galette::AvailabilitySet.new([Galette::Availability.new(@b, 0b1110)])

    combined = lhs & rhs

    assert_equal 0b1101, combined.for(@a).bitmap
    assert_equal 0b1110, combined.for(@b).bitmap
    assert combined.valid?
  end

  def test_intersect_to_invalid
    lhs = Galette::AvailabilitySet.new([Galette::Availability.new(@a, 0b0101)])
    rhs = Galette::AvailabilitySet.new([Galette::Availability.new(@a, 0b1010)])

    combined = lhs & rhs

    assert_equal 0b0000, combined.for(@a).bitmap
    refute combined.valid?
  end

  def test_union_same_spec
    lhs = Galette::AvailabilitySet.new([Galette::Availability.new(@a, 0b1101)])
    rhs = Galette::AvailabilitySet.new([Galette::Availability.new(@a, 0b1110)])

    combined = lhs | rhs

    assert_equal [@a], combined.specifications
    assert_equal 0b1111, combined.for(@a).bitmap
    assert combined.valid?
  end

  def test_union_different_specs
    lhs = Galette::AvailabilitySet.new([Galette::Availability.new(@a, 0b1101)])
    rhs = Galette::AvailabilitySet.new([Galette::Availability.new(@b, 0b1110)])

    combined = lhs | rhs

    assert_equal({}.compare_by_identity, combined.to_h)
    assert combined.valid?
  end
end
