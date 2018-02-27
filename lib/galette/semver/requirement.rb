# frozen_string_literal: true

module Galette
  module Semver
    class Requirement
      def initialize(specification, version_spec=nil)
        @specification = specification
        @version_spec = version_spec.to_s
        @gem_requirement = Gem::Requirement.new(version_spec)
      end

      def bitmap
        versions = @specification.versions
        if @gem_requirement.requirements[0][0] == '='
          desired_version = @gem_requirement.requirements[0][1].to_s
          version = versions.detect {|v| v.version == desired_version }
          version ? version.bitmap : 0
        else
          bitmap = @specification.versions.select do |version|
            !version.unneeded? && @gem_requirement.satisfied_by?(Gem::Version.new(version.version))
          end.map do |version|
            version.bitmap
          end.inject(:|) || 0
        end
      end

      def availability
        Availability.new(@specification, bitmap)
      end
    end
  end
end
