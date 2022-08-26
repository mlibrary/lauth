require_relative "handlers/request"
require_relative "handlers/response"

module Lauth
  module CLI
    module Handlers
      ::ROM::HTTP::Handlers.register(:handlers, request: Request, response: Response)
    end
  end
end
