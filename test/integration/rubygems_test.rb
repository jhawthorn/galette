require 'test_helper'

class RubygemsIntegrationTest < Minitest::Test
  def test_rubygems_specs_for_i18n
    availability = Galette::Rubygems.specs_from_requirements(['i18n'])

    specifications = availability.map(&:specification)
    assert_equal specifications.uniq, specifications

    names = specifications.map(&:name)
    assert_includes names, "i18n"
    assert_includes names, "concurrent-ruby"
  end
end
