require "rubygems/version"
require "galette/availability"

module Galette
  # A specification represents all available versions of a library, including
  # those the resolver has already ruled out.
  # This object is used without modification throughout the resolving process.
  class Specification
    class DSL
      def initialize(specification)
        @specification = specification
      end

      def version(name, requirements: [])
        @specification.versions << Galette::Version.new(
          @specification,
          1 << @specification.number_of_versions,
          name,
          requirements
        )
      end
    end

    attr_reader :name, :versions

    def initialize(name)
      @name = name
      @versions = [Version.new(self, 1, nil, [])]
      yield DSL.new(self)

      @versions.freeze
    end

    def full_availability
      Galette::Availability.new(self, (1 << (number_of_versions + 1)) - 1)
    end

    def semver_requirement(version_spec=nil)
      version_spec = Gem::Requirement.new(version_spec) unless version_spec.is_a?(Gem::Requirement)
      bitmap = versions.select do |version|
        !version.none? && version_spec.satisfied_by?(Gem::Version.new(version.version))
      end.map do |version|
        version.id
      end.inject(:|)
      Galette::Requirement.new(self, bitmap)
    end

    def number_of_versions
      versions.length
    end
  end
end
