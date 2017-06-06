module Galette
  class Version
    attr_reader :specification, :id, :version, :requirements

    def initialize(specification, id, version, requirements=[])
      @specification = specification
      @id = id
      @version = version
      @requirements = requirements
    end

    # Does this "version" represent "none" ie. not required
    def none?
      version == nil
    end
  end
end
