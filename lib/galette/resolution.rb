require "galette/availability_set"

module Galette
  class Resolution
    class ImpossibleResolutionError < StandardError
    end

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
      if !availabilities.valid?
        return nil
      end

      if index >= @specifications.length
        # We're all done! Hooray!
        return availabilities
      end

      spec = @specifications[index]

      if availabilities.for(spec).multiple?
        # We have a few versions to compare, it might be a good time to try and
        # prune our possible deps.
        availabilities = reduce_availabilities(availabilities)
      end

      return nil unless availabilities.valid?

      spec.versions.each do |version|
        next unless availabilities.include?(version)

        resolution = _resolve(availabilities & version.requirements, index + 1)
        return resolution if resolution

        availabilities = availabilities - version
        availabilities = reduce_availabilities(availabilities)
      end
      nil
    end

    def reduce_availabilities(availabilities)
      loop do
        mask = availabilities.map do |a|
          # If it may be unneeded, it can't apply any requirements
          next if a.includes_unneeded?

          a.versions.map(&:requirements).inject(:|)
        end.compact.inject(:&)

        if mask
          new_availabilities = availabilities & mask
          if new_availabilities == availabilities
            return availabilities
          else
            availabilities = new_availabilities
          end
        else
          return availabilities
        end
      end
    end

    def resolve
      result = _resolve(@availabilities)
      if !result
        raise ImpossibleResolutionError, "impossible to resolve dependencies"
      end

      result.map do |availability|
        # It should return exactly one version
        availability.version
      end.reject do |version|
        version.unneeded?
      end
    end
  end
end
