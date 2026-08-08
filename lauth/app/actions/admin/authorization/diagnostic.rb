# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      module Authorization
        class Diagnostic < Lauth::AdminAction
          include Deps[operation: "ops.admin.authorization.diagnostic"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            response.format = :json
            response.body = operation.call(
              ip: request.params[:ip],
              userid: request.params[:userid],
              collection: request.params[:collection]
            ).to_json
          rescue Lauth::Ops::Admin::Authorization::Diagnostic::NotFound => error
            response.format = :json
            response.status = 404
            response.body = error_body("not_found", error.message)
          rescue ArgumentError => error
            response.format = :json
            response.status = 400
            response.body = error_body("invalid_parameter", error.message)
          end
        end
      end
    end
  end
end
