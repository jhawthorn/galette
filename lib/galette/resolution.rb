require "galette/availability_set"

module Galette
  class Resolution
    def initialize(specifications, requirements)
      @availabilities =
        AvailabilitySet.new(specifications.map(&:full_availability))
      @requirements = AvailabilitySet.new(requirements)
      @availabilities &= @requirements
    end

    def resolve
      @availabilities.map do |availability|
        availability.versions[0]
      end.reject do |version|
        version.none?
      end
    end
  end
end
