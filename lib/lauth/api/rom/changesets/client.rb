module Lauth
  module API
    module ROM
      module Changesets
        class Client < ::ROM::Changeset::Stateful[:clients]
          command_type :upsert
          # relation :clients
          # register_as :client_create
          #
          # def execute(tuple)
          #   client_repo =  Lauth::Repositories::Client.new(Lauth::BDD.rom)
          #
          #   rv = client_repo.create(tuple)
          #
          #   [rv]
          #   #
          #   # nil
          #   # { id: 1, name: "Greg" }
          #   # tuple.to_a
          # end
        end
      end
    end
  end
end
