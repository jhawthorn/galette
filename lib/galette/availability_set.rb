module Galette
  class AvailabilitySet
    include Enumerable

    def initialize(availabilities=[], valid=nil)
      if availabilities.is_a?(Hash)
        @hash = availabilities
      else
        @hash = {}.compare_by_identity
        availabilities.each do |availability|
          @hash[availability.specification] = availability.bitmap
        end
      end
      @valid = valid.nil? ? !@hash.values.any?(&:zero?) : valid
      @hash.freeze
    end

    def &(other)
      new_valid = valid? && other.valid?

      new_hash = @hash.merge(other.to_h) do |_k, a, b|
        new_val = a & b
        new_valid = false if new_val == 0
        new_val
      end

      self.class.new(new_hash, new_valid)
    end

    def |(other)
      other_hash = other.to_h
      new_hash = {}

      # Any requirement unique to one half of the union is dropped
      @hash.each_pair do |k, a|
        next unless other_hash.has_key?(k)
        new_hash[k] = a | other_hash[k]
      end

      self.class.new(new_hash)
    end

    def include?(version)
      bitmap = @hash[version.specification]
      bitmap && bitmap[version.id] == 1
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
      Availability.new(specification, @hash[specification])
    end

    def each(&block)
      @hash.each_pair do |specification, bitmap|
        yield Availability.new(specification, bitmap)
      end
    end
  end
end
