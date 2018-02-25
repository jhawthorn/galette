module Galette
  class AvailabilitySet
    include Enumerable

    def initialize(availabilities=[], valid=nil)
      if availabilities.is_a?(Hash)
        @hash = availabilities
      else
        @hash = {}.compare_by_identity
        availabilities.each do |availability|
          @hash[availability.specification] = availability
        end
      end
      @valid = valid.nil? ? !@hash.values.any?(&:none?) : valid
      @hash.freeze
    end

    def &(other)
      new_valid = valid? && other.valid?

      new_hash = @hash.merge(other.to_h) do |_k, a, b|
        new_val = a & b
        new_valid = false if new_val.none?
        new_val
      end

      self.class.new(new_hash, new_valid)
    end

    def |(other)
      new_hash = {}

      # We don't use the result of this hash, we're abusing merge to get a set
      # of common keys and their values.
      # Any requirement unique to one half of the union is dropped
      @hash.merge(other.to_h) do |k, a, b|
        new_hash[k] = a | b
      end

      self.class.new(new_hash)
    end

    def to_h
      @hash
    end

    def specifications
      @hash.keys
    end

    def valid?
      @valid
    end

    def for(specification)
      @hash[specification]
    end

    def each(&block)
      @hash.values.each(&block)
    end
  end
end
