module Lauth
  module Actions
    class Authorize < Lauth::Action
      def handle(request, response)
        response.format = :json
        response.body = if request.params[:user] == "lauth-allowed"
          {determination: "allowed"}.to_json
        else
          {determination: "denied"}.to_json
        end
      end
    end
  end
end
