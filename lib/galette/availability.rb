module Galette
  class Availability
    attr_reader :name

    def initialize(specification, bitmap)
      @specification = specification
      @bitmap = bitmap
    end
  end
end
