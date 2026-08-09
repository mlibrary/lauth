# frozen_string_literal: true

require "json"

module Lauth
  module Actions
    module Admin
      module Institutions
        class Create < Lauth::AdminAction
          include Deps[operation: "ops.admin.institutions.create"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            result = operation.call(organization_name: request_body(request).fetch("organizationName"))
            response.format = :json
            response.status = 201
            response.body = {institution: Lauth::Presenters::Admin::Institution.call(result[:institution])}.to_json
          rescue JSON::ParserError, KeyError, ArgumentError => error
            response.format = :json
            response.status = 400
            response.body = error_body("invalid_parameter", error.message)
          end

          private

          def request_body(request)
            JSON.parse(request.body.read)
          end
        end
      end
    end
  end
end
