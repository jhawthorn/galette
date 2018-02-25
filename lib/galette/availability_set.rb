module Galette
  class AvailabilitySet
    include Enumerable

    def initialize(availabilities=[])
      if availabilities.is_a?(Hash)
        @hash = availabilities
      else
        @hash = {}
        availabilities.each do |availability|
          @hash[availability.specification] = availability
        end
      end
      @hash.freeze
    end

    def &(other)
      return self & self.class.new([other]) if other.is_a?(Galette::Availability)

      new_hash = @hash.merge(other.to_h) do |_k, a, b|
        a & b
      end

      self.class.new(new_hash, new_valid)
    end

    def to_h
      @hash
    end

    def specifications
      @hash.keys
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
