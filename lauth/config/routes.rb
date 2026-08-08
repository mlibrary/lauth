# frozen_string_literal: true

module Lauth
  class Routes < Hanami::Routes
    root { "Hello from Hanami" }
    get "/authorized", to: "authorize"
    get "/api/v1/institutions", to: "admin/institutions/search"
    get "/api/v1/institutions/:id/networks", to: "admin/institutions/networks"
    get "/api/v1/institutions/:id/grants", to: "admin/institutions/grants"
    get "/api/v1/networks", to: "admin/networks/search"
    get "/api/v1/objects", to: "admin/objects/search"
  end
end
