require "rubygems/version"
require "galette/availability"
require "galette/semver/requirement"

module Galette
  # A specification represents an immutable description of a library, and all
  # its available versions.
  # This object is referenced (but never modified) throughout the resolving process.
  class Specification
    class DSL
      def initialize(specification)
        @specification = specification
      end

      def version(name, requirements: [])
        @specification.versions << Galette::Version.new(
          @specification,
          @specification.number_of_versions,
          name,
          requirements
        )
      end
    end

    attr_reader :name, :versions

    def initialize(name)
      @name = name
      @versions = [Version.unneeded(self)]
      yield DSL.new(self)

      @versions.freeze
    end

    def full_availability
      Galette::Availability.new(self, (1 << (number_of_versions + 1)) - 1)
    end

    def requirement_semver(version_spec=nil)
      Galette::Semver::Requirement.new(self, version_spec).availability
    end

    def number_of_versions
      versions.length
    end

    def all_dependency_specifications
      queue = [self]
      all_specifications = Set.new

      while !queue.empty?
        specification = queue.shift
        next if all_specifications.include?(specification)
        all_specifications.add(specification)

        queue.concat specifications.map(&:requirements).map(&:specifications).uniq
      end

      all_specifications.to_a
    end
  end
end
