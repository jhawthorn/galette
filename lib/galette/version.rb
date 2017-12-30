module Galette
  class Version
    attr_reader :specification, :id, :version, :requirements

    def initialize(specification, id, version, requirements=[])
      @specification = specification
      @id = id
      @version = version
      @requirements = AvailabilitySet.new(requirements + [availability_self])
    end

    def availability_self
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
