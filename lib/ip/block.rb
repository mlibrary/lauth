module IP
  class Block
    attr_reader :min
    attr_reader :max
    attr_reader :size

    def initialize(min_address, max_address)
      raise ArgumentError, "Non IP::Address" unless min_address.is_a?(IP::Address) && max_address.is_a?(IP::Address)
      raise ArgumentError, "Invalid Block" unless min_address.to_i < max_address.to_i

      @min = min_address.to_i
      @max = max_address.to_i
      @size = @max - @min + 1
    end
  end
end
