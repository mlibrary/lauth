# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      module Networks
        class Search < Lauth::AdminAction
          include Deps[operation: "ops.admin.networks.search"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            response.format = :json
            result = operation.call(request.params)
            response.body = {networks: result[:networks].map { |network|
              network.to_h.slice(
                :uniqueIdentifier, :dlpsDNSName, :dlpsCIDRAddress, :dlpsAddressStart,
                :dlpsAddressEnd, :dlpsAccessSwitch, :inst, :lastModifiedTime, :dlpsDeleted
              )
            }}.to_json
          rescue Lauth::Repositories::NetworkRepo::InvalidSearch => error
            response.format = :json
            response.status = 400
            response.body = error_body("invalid_parameter", error.message)
          end
        end
      end
    end
  end
end
