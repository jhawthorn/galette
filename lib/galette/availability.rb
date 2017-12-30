module Galette
  class Availability
    attr_reader :specification, :bitmap

    def initialize(specification, bitmap)
      @specification = specification
      @bitmap = bitmap
    end

    def restrict(requirements)
      Availability.new(specification, bitmap & requirements.map(&:bitmap).inject(:&))
    end

    def versions
      @specification.versions.select do |version|
        !(version.id & bitmap).zero?
      end
    end

    def version
      raise "unique version expected" unless one?
      versions.first
    end

    def multiple?
      !none? && !one?
    end

    def one?
      return false if none?
      (bitmap & (bitmap - 1)) == 0
    end

    def none?
      bitmap == 0
    end
  end
end
