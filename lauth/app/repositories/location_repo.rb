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

      def search_by_path_and_server(path, server)
        search({dlpsPath: path, dlpsServer: server})
      end

      private

      def search(criteria, value = nil)
        criteria = {criteria => value} unless criteria.is_a?(Hash)
        patterns = criteria.transform_values do |search_value|
          raise ArgumentError, "search value is required" unless search_value.is_a?(String) && !search_value.empty?

          escaped = search_value.chars.map { |character| /[\\%_]/.match?(character) ? "\\#{character}" : character }.join
          "%#{escaped.tr("*", "%")}%"
        end
        dataset = locations
          .dataset
          .where(dlpsDeleted: "f")
          .where(patterns.map { |column, pattern| Sequel.ilike(column, pattern) }.reduce(:&))
          .order(:dlpsPath, :dlpsServer, :coll)
        locations.class.new(dataset).to_a
      end
    end
  end
end
