module Galette
  class Version
    attr_reader :specification, :id, :version, :requirements

    def initialize(specification, id, version, requirements=[])
      @specification = specification
      @id = id
      @version = version
      @requirements = AvailabilitySet.new(requirements + [to_availability])
    end

    def self.none(specification)
      new(specification, 1, nil, [])
    end

    def to_availability
      Galette::Availability.new(specification, id)
    end

    # Does this "version" represent "none" ie. not required
    def none?
      version == nil
    end

    def inspect
      "#<#{self.class} #{specification.name} #{version ? "=" + version : "UNNEEDED"}>"
    end
  end
end
