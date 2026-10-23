# frozen_string_literal: true

module Lauth
  class Routes < Hanami::Routes
    root { "Hello from Hanami" }
    get "/authorized", to: "authorize"
    get "/api/v1/institutions", to: "admin.institutions.search"
    post "/api/v1/institutions", to: "admin.institutions.create"
    get "/api/v1/institutions/:id/networks", to: "admin.institutions.networks"
    post "/api/v1/institutions/:id/networks", to: "admin.institutions.network_create"
    get "/api/v1/institutions/:id/grants", to: "admin.institutions.grants"
    get "/api/v1/networks", to: "admin.networks.search"
    get "/api/v1/locations", to: "admin.locations.search"
    get "/api/v1/collections", to: "admin.collections.search"
    get "/api/v1/collections/:id", to: "admin.collections.show"
    get "/api/v1/collections/:id/grants", to: "admin.collections.grants"
    get "/api/v1/users/:userid", to: "admin.users.show"
    get "/api/v1/access", to: "admin.access"
  end
end
