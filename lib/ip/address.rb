module IP
  class Address
    def initialize(str)
      str = IPAddress.ntoa(str) if str.is_a? Numeric
      ip_address = IPAddress.parse str

      if ip_address.ipv4?
        ip_address.prefix = 32
      elsif ip_address.ipv6?
        ip_address.prefix = 128
        raise ArgumentError, "IPv6 IP Address"
      else
        raise ArgumentError, "Invalid IP Address"
      end

      @value = ip_address.to_i
    end

    def to_i
      @value
    end

    def min
      to_i
    end

    def max
      to_i
    end

    def size
      1
    end
  end
end
