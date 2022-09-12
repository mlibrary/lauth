module Lauth
  module API
    module ROM
      module Commands
        class Client < ::ROM::SQL::Commands::Create
          relation :clients
          register_as :client_create

          def execute(tuple)
            client_repo = Lauth::API::Repositories::Client.new(Lauth::API::BDD.rom)

            rv = client_repo.create(tuple)

            [rv]
            #
            # nil
            # { id: 1, name: "Greg" }
            # tuple.to_a
          end
        end
      end
    end
  end
end
