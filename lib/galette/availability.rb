module Galette
  class Availability
    attr_reader :specification, :bitmap

    def initialize(specification, bitmap)
      @specification = specification
      @bitmap = bitmap
    end

    def versions
      @specification.versions.select do |version|
        !(version.id & bitmap).zero?
      end
    end
  end
end
