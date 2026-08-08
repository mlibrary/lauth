# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      module Institutions
        class Search < Lauth::AdminAction
          include Deps[operation: "ops.admin.institutions.search"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            response.format = :json
            response.body = operation.call(
              organization_name: request.params[:organizationName]
            ).to_json
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
