# auto_register: false
# frozen_string_literal: true

require "rom-repository"

module Lauth
  # The application repository.
  class Repository < ROM::Repository::Root
    include Deps[container: "persistence.rom"]
  end
end
