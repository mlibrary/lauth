module Lauth
  module Actions
    class Authorize < Lauth::Action

      def handle(request, response)
        response.format = :json
        if request.params[:user] == "lauth-allowed"
          response.body = { result: "allowed" }.to_json
        else
          response.body = { result: "denied" }.to_json
        end
      end
    end
  end
end
