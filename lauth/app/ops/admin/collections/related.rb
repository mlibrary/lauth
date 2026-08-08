# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Collections
        class Related
          include Deps[
            collection_repo: "repositories.collection_repo",
            grant_repo: "repositories.grant_repo"
          ]

          def show(collection_id:)
            collection = find_collection(collection_id)
            {collection: collection, grants: grant_repo.for_collection(collection_id)}
          end

          def grants(collection_id:)
            find_collection(collection_id)
            {grants: grant_repo.for_collection(collection_id)}
          end

          private

          def find_collection(id)
            collection_repo.find(id) || raise(NotFound, "collection not found")
          end

          class NotFound < StandardError; end
        end
      end
    end
  end
end
