# frozen_string_literal: true

module Lauth
  class AdminAction < Lauth::Action
    private

    def authenticate_admin(request, response)
      expected = "Bearer #{App.app["settings"].bearer_token}"
      return true if request.get_header("HTTP_AUTHORIZATION") == expected

      response.format = :json
      response.status = 401
      response.body = error_body("unauthorized", "Authentication is required")
      false
    end

    def error_body(code, message)
      {error: {code: code, message: message}}.to_json
    end
  end
end
