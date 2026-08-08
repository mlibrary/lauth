# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      module Collections
        class Grants < Lauth::AdminAction
          include Deps[operation: "ops.admin.collections.related"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            response.format = :json
            response.body = operation.grants(
              collection_id: request.params[:id]
            ).to_json
          rescue Lauth::Ops::Admin::Collections::Related::NotFound => error
            response.format = :json
            response.status = 404
            response.body = error_body("not_found", error.message)
          end
        end
      end
    end
  end
end
