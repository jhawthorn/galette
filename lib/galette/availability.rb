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
      raise "unique version expected" unless one?
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
  end
end
