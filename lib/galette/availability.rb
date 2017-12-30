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
  end
end
