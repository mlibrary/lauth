module Lauth
  module API
    module ROM
      module Commands
        class User < ::ROM::SQL::Commands::Create
          relation :users
          register_as :user_create

          def execute(tuple)
            user_repo = Lauth::API::Repositories::User.new(Lauth::API::BDD.rom)

            rv = user_repo.create(tuple)

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
