# frozen_string_literal: true

module Lauth
  # Defines application routes.
  class Routes < Hanami::Routes
    slice(:health, at: "/up") { root to: "show" }
    slice(:home, at: "/") { root to: "show" }
  end
end
