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
      requirements_by_specification =
        requirements.group_by(&:specification)
      availabilities.map do |availability|
        specification = availability.specification
        availability_requirements = requirements_by_specification.fetch(specification, [])
        availability = availability.restrict(availability_requirements)
        availability.versions[0]
      end
    end
  end
end
