# frozen_string_literal: true

module Lauth
  module Repositories
    class InstitutionRepo < ROM::Repository[:institutions]
      include Deps[container: "persistence.rom"]

      struct_namespace Lauth
      commands :create

      def search_by_organization_name(value)
        pattern = wildcard_pattern(value)
        dataset = institutions
          .dataset
          .where(dlpsDeleted: "f")
          .where(Sequel.ilike(:organizationName, pattern))
          .order(:uniqueIdentifier)
        institutions.class.new(dataset).to_a
      end

      def find(id)
        dataset = institutions
          .dataset
          .where(uniqueIdentifier: id, dlpsDeleted: "f")
        institutions.class.new(dataset).to_a.first
      end

      private

      def wildcard_pattern(value)
        raise ArgumentError, "organizationName is required" unless value.is_a?(String) && !value.empty?

        Lauth::SearchPattern.wildcard(value)
      end
    end
  end
end
