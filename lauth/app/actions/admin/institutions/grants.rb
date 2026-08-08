# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      module Institutions
        class Grants < Lauth::AdminAction
          include Deps[operation: "ops.admin.institutions.related"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            response.format = :json
            response.body = operation.grants(
              institution_id: request.params[:id]
            ).to_json
          rescue Lauth::Ops::Admin::Institutions::Related::NotFound => error
            response.format = :json
            response.status = 404
            response.body = error_body("not_found", error.message)
          end
        end
      end
    end
  end
end
