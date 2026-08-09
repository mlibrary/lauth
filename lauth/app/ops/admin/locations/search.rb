# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Locations
        class Search
          include Deps[location_repo: "repositories.location_repo"]

          def call(path: nil, server: nil)
            raise ArgumentError, "at least one search value is required" if path.nil? && server.nil?

            locations = if path && server
              location_repo.search_by_path_and_server(path, server)
            elsif path
              location_repo.search_by_path(path)
            else
              location_repo.search_by_server(server)
            end

            {locations: locations}
          end
        end
      end
    end
  end
end
