# frozen_string_literal: true

require "ipaddr"

module Lauth
  class IPv4CIDR
    attr_reader :address, :prefix, :start, :end

    def self.parse(value)
      new(value)
    end

    def initialize(value)
      address, prefix = value.to_s.split("/", 2)
      raise ArgumentError, "cidr must be an IPv4 slash-notation string" unless address && prefix&.match?(/\A\d+\z/)
      raise ArgumentError, "cidr must be an IPv4 slash-notation string" if address.include?(":")

      prefix = Integer(prefix, 10)
      raise ArgumentError, "cidr prefix must be between 0 and 32" unless prefix.between?(0, 32)

      parsed = IPAddr.new(address)
      raise ArgumentError, "cidr must be an IPv4 slash-notation string" unless parsed.ipv4?

      @prefix = prefix
      mask = prefix.zero? ? 0 : (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF
      @start = parsed.to_i & mask
      @end = @start + (1 << (32 - prefix)) - 1
      @address = IPAddr.new(@start, Socket::AF_INET).to_s
    rescue IPAddr::InvalidAddressError
      raise ArgumentError, "cidr must be an IPv4 slash-notation string"
    end

    def to_s
      "#{address}/#{prefix}"
    end
  end
end
