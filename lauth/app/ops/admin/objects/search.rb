# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Objects
        class Search
          include Deps["repositories.location_repo"]

          def call(path: nil, server: nil)
            raise ArgumentError, "exactly one search value is required" unless path.nil? ^ server.nil?

            {objects: path ? location_repo.search_by_path(path) : location_repo.search_by_server(server)}
          end
        end
      end
    end
  end
end
