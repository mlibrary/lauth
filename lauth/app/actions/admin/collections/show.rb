# frozen_string_literal: true

module Lauth
  module Actions
    module Admin
      module Collections
        class Show < Lauth::AdminAction
          include Deps[operation: "ops.admin.collections.related"]

          def handle(request, response)
            return unless authenticate_admin(request, response)

            response.format = :json
            result = operation.show(
              collection_id: request.params[:id]
            )
            result[:collection] = Lauth::Presenters::Admin::Collection.call(result[:collection])
            response.body = result.to_json
          rescue Lauth::Ops::Admin::Collections::Related::NotFound => error
            response.format = :json
            response.status = 404
            response.body = error_body("not_found", error.message)
          end
        end
      end
    end
  end
end
