module Galette
  class AvailabilitySet
    include Enumerable

    def initialize(availabilities=[])
      @hash = {}
      availabilities.each do |availability|
        @hash[availability.specification] = availability
      end
      @hash.freeze
    end

    def &(other)
      return self & self.class.new([other]) if other.is_a?(Galette::Availability)

      new_hash = @hash.dup
      # Fixme: can this be replaced by Hash#merge ?
      other.each do |availability|
        specification = availability.specification
        if @hash.key?(specification)
          new_hash[specification] &= availability
        else
          new_hash[specification] = availability
        end
      end
      self.class.new(new_hash.values)
    end

    def valid?
      !@hash.values.any?(&:none?)
    end

    def for(specification)
      @hash[specification]
    end

    def each(&block)
      @hash.values.each(&block)
    end
  end
end
