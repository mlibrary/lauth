# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      module Institutions
        class Networks < Lauth::AdminAction
          include Deps[operation: "ops.admin.institutions.related"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            response.format = :json
            result = operation.networks(
              institution_id: request.params[:id]
            )
            response.body = {networks: result[:networks].map { |network|
              Lauth::Presenters::Admin::Network.call(network)
            }}.to_json
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
