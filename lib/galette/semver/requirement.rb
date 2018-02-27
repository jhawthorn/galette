module Galette
  module Semver
    class Requirement
      def initialize(specification, version_spec=nil)
        @specification = specification
        @version_spec = version_spec.to_s
        @gem_requirement = Gem::Requirement.new(version_spec)
      end

      def bitmap
        bitmap = @specification.versions.select do |version|
          !version.unneeded? && @gem_requirement.satisfied_by?(Gem::Version.new(version.version))
        end.map do |version|
          version.bitmap
        end.inject(:|) || 0
      end

      def availability
        Availability.new(@specification, bitmap)
      end
    end
  end
end
