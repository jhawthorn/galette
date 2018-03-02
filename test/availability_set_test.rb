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

    (@a.versions + @b.versions).each do |v|
      refute availability.include?(v)
    end
  end
end
