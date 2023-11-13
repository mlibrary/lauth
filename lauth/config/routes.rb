# frozen_string_literal: true

module Lauth
  class Routes < Hanami::Routes
    root { "Hello from Hanami" }
    get "/authorized", to: "authorize"
  end
end
