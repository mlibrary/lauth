module Lauth
  module Actions
    class Authorize < Lauth::Action
      include Deps["repositories.grant_repo"]
      def handle(request, response)
        response.format = :json

        result = Lauth::Ops::Authorize.new(
          request: Lauth::Access::Request.new(
            user: request.params[:user],
            uri: request.params[:uri],
            client_ip: request.params[:ip]
          )
        ).call

        response.body = result.to_h.to_json
      end

    end
  end
end
