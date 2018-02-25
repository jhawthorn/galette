require "galette/availability_set"

module Galette
  class Resolution
    def initialize(specifications, requirements=nil)
      if requirements.nil?
        requirements = specifications
        specifications = requirements.specifications
      end
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

      versions = availabilities.for(spec).versions

      if versions.count > 1
        # We have a few versions to compare, it might be a good time to try and
        # prune our possible deps.

        mask = availabilities.map do |a|
          a.versions.map(&:requirements).inject(:|)
        end.compact.inject(:&)

        availabilities &= mask if mask
      end

      versions.each do |version|
        resolution = _resolve(availabilities & version.requirements, index + 1)
        return resolution if resolution
      end
      nil
    end

    def resolve
      result = _resolve(@availabilities)
      raise "resolution impossible" if !result
      result.map do |availability|
        # It should return exactly one version
        availability.versions[0]
      end.reject do |version|
        version.unneeded?
      end
    end
  end
end
