# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      module Locations
        class Search < Lauth::AdminAction
          include Deps[operation: "ops.admin.locations.search"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            response.format = :json
            result = operation.call(
              path: request.params[:path],
              server: request.params[:server]
            )
            response.body = {locations: result[:locations].map { |location|
              Lauth::Presenters::Admin::Location.call(location)
            }}.to_json
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
