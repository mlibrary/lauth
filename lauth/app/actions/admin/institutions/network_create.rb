# frozen_string_literal: true

require "json"

module Lauth
  module Actions
    module Admin
      module Institutions
        class NetworkCreate < Lauth::AdminAction
          include Deps[operation: "ops.admin.institutions.network_create"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            body = JSON.parse(request.body.read)
            raise ArgumentError, "request body must be an object" unless body.is_a?(Hash)

            result = operation.call(
              institution_id: request.params[:id],
              cidrs: body["cidrs"],
              access_switch: body["accessSwitch"]
            )
            response.format = :json
            response.status = 201
            response.body = {networks: result[:networks].map { |network|
              Lauth::Presenters::Admin::Network.call(network)
            }}.to_json
          rescue JSON::ParserError, ArgumentError => error
            response.format = :json
            response.status = 400
            response.body = error_body("invalid_parameter", error.message)
          rescue Lauth::Ops::Admin::Institutions::NetworkCreate::NotFound => error
            response.format = :json
            response.status = 404
            response.body = error_body("not_found", error.message)
          end
        end
      end
    end
  end
end
