# frozen_string_literal: true

module Lauth
  class Routes < Hanami::Routes
    root { "Hello from Hanami" }
    get "/authorized", to: "authorize"
    get "/api/v1/institutions", to: "admin/institutions/search"
    get "/api/v1/networks", to: "admin/networks/search"
  end
end
