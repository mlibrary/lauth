module IP
  class Network
    attr_reader :address
    attr_reader :prefix
    attr_reader :netmask
    attr_reader :min
    attr_reader :max
    attr_reader :size

    def initialize(ip_block)
      raise ArgumentError, "Non IP::Block" unless ip_block.is_a?(IP::Block)

      prefix = 30
      min_ip_address = IPAddress::IPv4.parse_u32(ip_block.min)
      min_ip_address.prefix = prefix
      max_ip_address = IPAddress::IPv4.parse_u32(ip_block.max)
      max_ip_address.prefix = prefix

      until min_ip_address.network_u32 == max_ip_address.network_u32
        prefix -= 1
        min_ip_address.prefix = prefix
        max_ip_address.prefix = prefix
      end

      @address = min_ip_address.network.address
      @prefix = min_ip_address.prefix
      @netmask = min_ip_address.netmask
      @min = min_ip_address.network_u32
      @max = min_ip_address.broadcast_u32
      @size = @max - @min + 1
    end
  end
end
