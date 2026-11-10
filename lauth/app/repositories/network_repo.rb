# frozen_string_literal: true

module Lauth
  module Repositories
    class NetworkRepo < ROM::Repository[:networks]
      include Deps[container: "persistence.rom"]

      struct_namespace Lauth
      commands :create

      def create_batch(attributes)
        container.gateways[:default].connection.transaction do
          attributes.map { |network| create(**network) }
        end
      end

      def search_by_ip(value)
        range = Lauth::AddressRange.from_ip(value)
        search_overlapping(range)
      rescue ArgumentError => error
        raise InvalidSearch, error.message
      end

      def search_by_prefix(value)
        raise InvalidSearch, "prefix must be a string" unless value.is_a?(String)

        range = Lauth::AddressRange.from_prefix(value)
        search_overlapping(range)
      rescue ArgumentError => error
        raise InvalidSearch, error.message
      end

      def search_by_cidr(value)
        raise InvalidSearch, "cidr must be a string" unless value.is_a?(String)

        search_overlapping(Lauth::AddressRange.from_cidr(value))
      rescue ArgumentError
        raise InvalidSearch, "invalid CIDR"
      end

      def search_by_range(start_value:, end_value:)
        range = Lauth::AddressRange.from_values(start_value, end_value)
        search_overlapping(range)
      rescue ArgumentError => error
        raise InvalidSearch, error.message
      end

      def for_institution(institution_id)
        dataset = networks
          .dataset
          .where(inst: institution_id, dlpsDeleted: "f")
          .order(:dlpsAddressStart, :dlpsAccessSwitch, :uniqueIdentifier)
        networks.class.new(dataset).to_a
      end

      private

      def search_overlapping(range)
        raise InvalidSearch, "range start must not exceed range end" if range.start > range.end

        dataset = networks
          .dataset
          .where(dlpsDeleted: "f")
          .where(Sequel.lit("dlpsAddressStart <= ? AND dlpsAddressEnd >= ?", range.end, range.start))
          .order(:dlpsAddressStart, :dlpsAccessSwitch, :uniqueIdentifier)
        networks.class.new(dataset).to_a
      end

      class InvalidSearch < ArgumentError; end
    end
  end
end
