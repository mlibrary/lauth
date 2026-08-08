# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Collections
        class Search
          include Deps[collection_repo: "repositories.collection_repo"]

          def call(identifier:)
            {collections: collection_repo.search_by_identifier(identifier)}
          end
        end
      end
    end
  end
end
