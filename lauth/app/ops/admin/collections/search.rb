# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Collections
        class Search
          include Deps[collection_repo: "repositories.collection_repo"]

          def call(id:)
            {collections: collection_repo.search_by_identifier(id)}
          end
        end
      end
    end
  end
end
