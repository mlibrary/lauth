# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      class Access < Lauth::AdminAction
        include Deps[
          collection_repo: "repositories.collection_repo",
          access: "ops.access"
        ]

        def handle(request, response)
          return unless authenticate_admin(request, response)

          collection = collection_repo.find(request.params[:collection])
          raise NotFound, "collection not found" unless collection
          raise ArgumentError, "userid is required" unless request.params[:userid].is_a?(String) && !request.params[:userid].empty?

          response.format = :json
          response.body = access.call(
            collection: collection,
            user: request.params[:userid],
            client_ip: request.params[:ip]
          ).to_h.to_json
        rescue NotFound => error
          response.format = :json
          response.status = 404
          response.body = error_body("not_found", error.message)
        rescue ArgumentError => error
          response.format = :json
          response.status = 400
          response.body = error_body("invalid_parameter", error.message)
        end

        class NotFound < StandardError; end
      end
    end
  end
end
