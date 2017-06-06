module Galette
  class Resolution
    attr_reader :specifications, :availabilities, :requirements

    def initialize(specifications, requirements)
      @specifications = specifications
      @availabilities = specifications.map(&:full_availability)
      @requirements = requirements
    end

    def resolve
      return [] if requirements.empty?
      availabilities.map do |availability|
        specification = availability.specification
        requirements.each do |r|
          next unless r.specification == specification
          availability = Availability.new(specification, availability.bitmap & r.bitmap)
        end
        availability.versions[0]
      end
    end
  end
end
