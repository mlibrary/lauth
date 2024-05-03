module Lauth
  module Actions
    class Authorize < Lauth::Action
      def handle(request, response)
        response.format = :json

        if request.has_header?("HTTP_AUTHORIZATION")
          if request.get_header("HTTP_AUTHORIZATION") == "Bearer " + App.app["settings"].bearer_token
            result = Lauth::Ops::Authorize.new(
              request: Lauth::Access::Request.new(
                user: request.params[:user],
                uri: request.params[:uri],
                client_ip: request.params[:ip]
              )
            ).call

            response.body = result.to_h.to_json
          else
            App.app["logger"].error("Request HTTP authorization failed.")
            response.status = 401 # Unauthorized
            response.body = Lauth::Access::Request.new.to_h.to_json
          end
        else
          App.app["logger"].error("Request missing HTTP authorization header.")
          response.status = 401 # Unauthorized
          response.body = Lauth::Access::Request.new.to_h.to_json
        end
      end
    end
  end
end
