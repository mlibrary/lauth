# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Collections
        class Grants
          include Deps[
            collection_repo: "repositories.collection_repo",
            grant_repo: "repositories.grant_repo"
          ]

          def call(collection_id:)
            raise NotFound, "collection not found" unless collection_repo.find(collection_id)

            {grants: grant_repo.for_collection(collection_id)}
          end

          class NotFound < StandardError; end
        end
      end
    end
  end
end
