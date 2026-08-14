# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      module Collections
        class Grants < Lauth::AdminAction
          include Deps[operation: "ops.admin.collections.grants"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            response.format = :json
            result = operation.call(
              collection_id: request.params[:id]
            )
            result[:grants] = result[:grants].map { |grant|
              Lauth::Presenters::Admin::Grant.call(grant)
            }
            response.body = result.to_json
          rescue Lauth::Ops::Admin::Collections::Grants::NotFound => error
            response.format = :json
            response.status = 404
            response.body = error_body("not_found", error.message)
          end
        end
      end
    end
  end
end
