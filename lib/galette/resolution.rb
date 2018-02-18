require "galette/availability_set"

module Galette
  class Resolution
    def initialize(specifications, requirements)
      @specifications = specifications
      @availabilities =
        AvailabilitySet.new(specifications.map(&:full_availability))
      @requirements = AvailabilitySet.new(requirements)
      @availabilities &= @requirements
    end

    def _resolve(availabilities, index=0)
      return nil unless availabilities.valid?

      if index >= @specifications.length
        # We're all done! Hooray!
        return availabilities
      end

      spec = @specifications[index]
      availabilities.for(spec).versions.each do |version|
        resolution = _resolve(availabilities & version.requirements, index + 1)
        return resolution if resolution
      end
      nil
    end

    def resolve
      _resolve(@availabilities).map do |availability|
        # It should return exactly one version
        availability.versions[0]
      end.reject do |version|
        version.none?
      end
    end
  end
end
