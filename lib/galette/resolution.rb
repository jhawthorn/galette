module Galette
  class Resolution
    attr_reader :availabilities, :requirements

    def initialize(availabilities, requirements)
      @availabilities = availabilities
      @requirements = requirements
    end

    def resolve
      return [] if requirements.empty?
      availabilities.map do |availability|
        availability.versions[1]
      end
    end
  end
end
