module Galette
  class Version
    attr_reader :specification, :id, :version, :requirements
    attr_writer :requirements

    def initialize(specification, id, version, requirements=[])
      @specification = specification
      @id = id
      @version = version
      @requirements = AvailabilitySet.new(requirements + [to_availability])
    end

    def bitmap
      @id
    end

    def self.unneeded(specification)
      new(specification, 1, nil, [])
    end

    def to_availability
      Galette::Availability.new(specification, bitmap)
    end

    # Does this "version" represent "unneeded" ie. not required
    def unneeded?
      version == nil
    end

    def inspect
      "#<#{self.class} #{specification.name} #{version ? "=" + version : "UNNEEDED"}>"
    end
  end
end
