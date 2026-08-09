# frozen_string_literal: true

module Lauth
  module Repositories
    class NetworkRepo < ROM::Repository[:networks]
      class InvalidSearch < ArgumentError; end

      include Deps[container: "persistence.rom"]

      struct_namespace Lauth

      def search_by_ip(value)
        search_overlapping(range_for_ip(value))
      end

      def search_by_prefix(value)
        raise InvalidSearch, "prefix must be a string" unless value.is_a?(String)

        octets = parse_octets(value, allow_partial: true)
        start = octets + [0] * (4 - octets.length)
        bits = octets.length * 8
        search_overlapping(AddressRange.new(start: to_integer(start), end: to_integer(start) + (1 << (32 - bits)) - 1))
      end

      def search_by_cidr(value)
        raise InvalidSearch, "cidr must be a string" unless value.is_a?(String)

        address, bits = value.split("/", 2)
        raise InvalidSearch, "invalid CIDR" unless address && bits&.match?(/\A\d+\z/)

        bits = Integer(bits, 10)
        raise InvalidSearch, "invalid CIDR prefix" unless bits.between?(0, 32)

        start = to_integer(parse_octets(address)) & (0xFFFFFFFF << (32 - bits))
        search_overlapping(AddressRange.new(start: start, end: start + (1 << (32 - bits)) - 1))
      rescue ArgumentError
        raise InvalidSearch, "invalid CIDR"
      end

      def search_by_range(start_value:, end_value:)
        search_overlapping(AddressRange.new(start: normalize_integer(start_value), end: normalize_integer(end_value)))
      end

      def for_institution(institution_id)
        dataset = networks
          .dataset
          .where(inst: institution_id, dlpsDeleted: "f")
          .order(:dlpsAddressStart, :dlpsAccessSwitch, :uniqueIdentifier)
        networks.class.new(dataset).to_a
      end

      private

      AddressRange = Data.define(:start, :end)

      def range_for_ip(value)
        integer = normalize_integer(value)
        AddressRange.new(start: integer, end: integer)
      end

      def search_overlapping(range)
        raise InvalidSearch, "range start must not exceed range end" if range.start > range.end

        dataset = networks
          .dataset
          .where(dlpsDeleted: "f")
          .where(Sequel.lit("dlpsAddressStart <= ? AND dlpsAddressEnd >= ?", range.end, range.start))
          .order(:dlpsAddressStart, :dlpsAccessSwitch, :uniqueIdentifier)
        networks.class.new(dataset).to_a
      end

      def parse_octets(value, allow_partial: false)
        octets = value.split(".")
        valid_length = allow_partial ? octets.length.between?(1, 4) : octets.length == 4
        raise InvalidSearch, "invalid IPv4 address" unless valid_length
        raise InvalidSearch, "invalid IPv4 address" unless octets.all? { |octet| octet.match?(/\A\d+\z/) && octet.to_i.between?(0, 255) }

        octets.map(&:to_i)
      end

      def normalize_integer(value)
        integer = if value.is_a?(Integer)
          value
        elsif value.is_a?(String) && value.match?(/\A\d+\z/)
          Integer(value, 10)
        elsif value.is_a?(String)
          to_integer(parse_octets(value))
        end
        raise InvalidSearch, "invalid IPv4 address" unless integer&.between?(0, 0xFFFFFFFF)

        integer
      end

      def to_integer(octets)
        octets.reduce(0) { |value, octet| (value << 8) + octet }
      end
    end
  end
end
