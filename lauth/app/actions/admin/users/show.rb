# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      module Users
        class Show < Lauth::AdminAction
          include Deps[operation: "ops.admin.users.show"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            response.format = :json
            response.body = operation.call(userid: request.params[:userid]).to_json
          rescue Lauth::Ops::Admin::Users::Show::NotFound => error
            response.format = :json
            response.status = 404
            response.body = error_body("not_found", error.message)
          end
        end
      end
    end
  end
end
