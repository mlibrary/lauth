module Lauth
  module Actions
    class Authorize < Lauth::Action
      def handle(request, response)
        response.format = :json

        result = Lauth::Ops::Authorize.new.call(
          request: Lauth::Access::Request.new(
            user: request.params[:user],
            uri: request.params[:uri],
            client_ip: request.params[:ip]
          )
        )

        response.body = result.to_h.to_json
      end
    end
  end
end
