# frozen_string_literal: true

module Lauth
  module Repositories
    class InstitutionRepo < ROM::Repository[:institutions]
      include Deps[container: "persistence.rom"]

      struct_namespace Lauth

      def search_by_organization_name(value)
        pattern = wildcard_pattern(value)
        institutions
          .dataset
          .where(dlpsDeleted: "f")
          .where(Sequel.ilike(:organizationName, pattern))
          .select(:uniqueIdentifier, :organizationName)
          .order(:uniqueIdentifier)
          .to_a
      end

      private

      def wildcard_pattern(value)
        raise ArgumentError, "organizationName is required" unless value.is_a?(String) && !value.empty?

        escaped = value.chars.map { |character| /[\\%_]/.match?(character) ? "\\#{character}" : character }.join
        "%#{escaped.tr("*", "%")}%"
      end
    end
  end
end
