module Galette
  class Availability
    attr_reader :specification, :bitmap

    def initialize(specification, bitmap)
      @specification = specification
      @bitmap = bitmap
    end

    def self.none(specification)
      new(specification, 0)
    end

    def &(other)
      self.class.new(specification, bitmap & other.bitmap)
    end

    def |(other)
      self.class.new(specification, bitmap | other.bitmap)
    end

    def versions
      @specification.versions.select do |version|
        @bitmap[version.id] == 1
      end
    end

    def version
      if !one?
        if none?
          raise "Called Availability#version with no available versions of #{specification.name}"
        else # many
          raise "Called Availability#version with multiple available versions of #{specification.name}"
        end
      end
      versions.first
    end

    if RUBY_VERSION >= "2.5"
      def multiple?
        bitmap.anybits?(bitmap - 1)
      end
    else
      def multiple?
        bitmap & (bitmap - 1) != 0
      end
    end

    def one?
      !none? && !multiple?
    end

    def none?
      bitmap == 0
    end

    def includes_unneeded?
      bitmap[0] == 1 && specification.versions[0].unneeded?
    end

    def ==(other)
      equal?(other) ||
        other.instance_of?(Availability) &&
        specification == other.specification &&
        bitmap == other.bitmap
    end

    def inspect
      "#<#{self.class} #{specification.name} (#{versions.count}/#{specification.number_of_versions})>"
    end
  end
end
