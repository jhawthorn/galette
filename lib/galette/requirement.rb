module Galette
  class Requirement
    attr_reader :specification, :bitmap

    def initialize(specification, bitmap)
      @specification = specification
      @bitmap = bitmap
    end
  end
end
