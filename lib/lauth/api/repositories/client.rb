module Lauth
  module API
    module Repositories
      class Client < ::ROM::Repository[:clients]
        # commands :create, update: :by_pk, delete: :by_pk

        struct_namespace Lauth::API::ROM::Entities
        auto_struct true

        def index
          clients
        end

        def create(document)
          clients.changeset(Lauth::API::ROM::Changesets::ClientCreate, document).commit
        rescue => _e
          nil
        end

        def read(id)
          clients.where(id: id).one
        end

        def update(document)
          id = document["data"]["id"]
          client = read(id)
          return nil unless client

          clients.where(id: id).changeset(Lauth::API::ROM::Changesets::ClientUpdate, document).commit
        end

        def delete(id)
          client = read(id)
          return nil unless client

          clients.where(id: id).delete
        end
      end
    end
  end
end
