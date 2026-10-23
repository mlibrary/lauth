# frozen_string_literal: true

module Lauth
  module Repositories
    class NetworkRepo < ROM::Repository[:networks]
      include Deps[container: "persistence.rom"]

      struct_namespace Lauth
      commands :create

      def create_batch(attributes)
        container.gateways[:default].connection.transaction do
          conflicts = attributes.filter_map { |network| find_active_owner(network) }
          raise DuplicateCIDR, conflicts unless conflicts.empty?

          attributes.map { |network| create(**network) }
        end
      rescue ROM::SQL::UniqueConstraintError, Sequel::UniqueConstraintViolation
        # A concurrent writer can pass the duplicate check; resolve the committed
        # owner so the API still returns the public duplicate contract.
        conflicts = attributes.filter_map { |network| find_active_owner(network) }
        raise DuplicateCIDR, conflicts unless conflicts.empty?

        raise
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

      def find_active_owner(network)
        row = container.gateways[:default].connection[:aa_network]
          .join(:aa_inst, uniqueIdentifier: :inst)
          .where(
            Sequel[:aa_network][:dlpsAddressStart] => network.fetch(:dlpsAddressStart),
            Sequel[:aa_network][:dlpsAddressEnd] => network.fetch(:dlpsAddressEnd),
            Sequel[:aa_network][:dlpsDeleted] => "f"
          )
          .select(
            Sequel[:aa_inst][:uniqueIdentifier].as(:owner_id),
            Sequel[:aa_inst][:organizationName].as(:owner_name)
          ).first
        return unless row

        DuplicateCIDR::Conflict.new(
          network.fetch(:dlpsCIDRAddress), row[:owner_id], row[:owner_name]
        )
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

      class InvalidSearch < ArgumentError; end

      class DuplicateCIDR < ArgumentError
        attr_reader :canonical

        def initialize(conflicts)
          @canonical = conflicts.first.canonical
          message = conflicts.map do |conflict|
            "cidr #{conflict.canonical} already exists for institution #{conflict.owner_id} (#{conflict.owner_name})"
          end.join("; ")
          super(message)
        end

        Conflict = Data.define(:canonical, :owner_id, :owner_name)
      end
    end
  end
end
