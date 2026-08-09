# frozen_string_literal: true

module Lauth
  module Repositories
    class LocationRepo < ROM::Repository[:locations]
      include Deps[container: "persistence.rom"]

      struct_namespace Lauth

      def search_by_path(value)
        search(:dlpsPath, value)
      end

      def search_by_server(value)
        search(:dlpsServer, value)
      end

      private

      def search(column, value)
        raise ArgumentError, "search value is required" unless value.is_a?(String) && !value.empty?

        escaped = value.chars.map { |character| /[\\%_]/.match?(character) ? "\\#{character}" : character }.join
        pattern = "%#{escaped}%"
        dataset = locations
          .dataset
          .where(dlpsDeleted: "f")
          .where(Sequel.ilike(column, pattern))
          .order(:dlpsPath, :dlpsServer, :coll)
        locations.class.new(dataset).to_a
      end
    end
  end
end
