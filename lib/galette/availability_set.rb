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
      new_hash = @hash.dup
      other.each do |availability|
        new_hash[availability.specification] &= availability
      end
      self.class.new(new_hash.values)
    end

    def for(specification)
      @hash[specification]
    end

    def each(&block)
      @hash.values.each(&block)
    end
  end
end
