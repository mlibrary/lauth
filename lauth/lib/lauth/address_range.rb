# frozen_string_literal: true

module Lauth
  class AddressRange
    attr_reader :start, :end

    def self.from_ip(value)
      integer = normalize(value)
      new(integer, integer)
    end

    def self.from_prefix(value)
      octets = parse_octets(value, allow_partial: true)
      start = to_integer(octets + [0] * (4 - octets.length))
      bits = octets.length * 8
      new(start, start + (1 << (32 - bits)) - 1)
    end

    def self.from_cidr(value)
      address, bits = value.split("/", 2)
      raise ArgumentError, "invalid CIDR" unless address && bits&.match?(/\A\d+\z/)

      bits = Integer(bits, 10)
      raise ArgumentError, "invalid CIDR prefix" unless bits.between?(0, 32)

      start = to_integer(parse_octets(address)) & (0xFFFFFFFF << (32 - bits))
      new(start, start + (1 << (32 - bits)) - 1)
    rescue ArgumentError => error
      raise error if error.message.start_with?("invalid CIDR")

      raise ArgumentError, "invalid CIDR"
    end

    def self.from_values(start_value, end_value)
      new(normalize(start_value), normalize(end_value))
    end

    def initialize(start_value, end_value)
      raise ArgumentError, "invalid IPv4 address" unless start_value.between?(0, 0xFFFFFFFF) && end_value.between?(0, 0xFFFFFFFF)

      @start = start_value
      @end = end_value
      freeze
    end

    def self.parse_octets(value, allow_partial: false)
      octets = value.split(".")
      valid_length = allow_partial ? octets.length.between?(1, 4) : octets.length == 4
      raise ArgumentError, "invalid IPv4 address" unless valid_length
      raise ArgumentError, "invalid IPv4 address" unless octets.all? { |octet| octet.match?(/\A\d+\z/) && octet.to_i.between?(0, 255) }

      octets.map(&:to_i)
    end
    private_class_method :parse_octets

    def self.normalize(value)
      integer = if value.is_a?(Integer)
        value
      elsif value.is_a?(String) && value.match?(/\A\d+\z/)
        Integer(value, 10)
      elsif value.is_a?(String)
        to_integer(parse_octets(value))
      end
      raise ArgumentError, "invalid IPv4 address" unless integer&.between?(0, 0xFFFFFFFF)

      integer
    end
    private_class_method :normalize

    def self.to_integer(octets)
      octets.reduce(0) { |value, octet| (value << 8) + octet }
    end
    private_class_method :to_integer
  end
end
