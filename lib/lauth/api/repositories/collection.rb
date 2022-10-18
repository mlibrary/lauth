module Lauth
  module API
    module Repositories
      class Collection < ::ROM::Repository[:collections]
        # commands :create, update: :by_pk, delete: :by_pk

        struct_namespace Lauth::API::ROM::Entities
        auto_struct true

        def index
          undeleted_collections
        end

        def create(document)
          id = document["data"]["id"]
          collection = undeleted_collections.where(uniqueIdentifier: id).one
          return nil if collection

          if deleted_collections.where(uniqueIdentifier: id).one
            deleted_collections.where(uniqueIdentifier: id).changeset(Lauth::API::ROM::Changesets::CollectionUpdate, document).commit
          else
            undeleted_collections.changeset(Lauth::API::ROM::Changesets::CollectionCreate, document).commit
          end

          undeleted_collections.where(uniqueIdentifier: id).one
        end

        def read(id)
          undeleted_collections.where(uniqueIdentifier: id).one
        end

        def update(document)
          id = document["data"]["id"]
          collection = deleted_collections.where(uniqueIdentifier: id).one
          return nil if collection

          if undeleted_collections.where(uniqueIdentifier: id).one
            undeleted_collections.where(uniqueIdentifier: id).changeset(Lauth::API::ROM::Changesets::CollectionUpdate, document).commit
          end

          undeleted_collections.where(uniqueIdentifier: id).one
        end

        def delete(id)
          collection = read(id)
          undeleted_collections.where(uniqueIdentifier: id).update(dlpsDeleted: "t") if collection
          collection
        end

        def by_request_uri(server, uri)
          collections.join(locations)
            .where(locations[:dlpsServer].is(server))
            .where(Sequel.ilike(uri, locations[:dlpsPath]))
            .order(Sequel.function(:length, locations[:dlpsPath])).reverse.to_a
        end

        protected

        def all_collections
          collections.rename(uniqueIdentifier: :id, commonName: :name)
        end

        def undeleted_collections
          collections.where(dlpsDeleted: "f").rename(uniqueIdentifier: :id, commonName: :name)
        end

        def deleted_collections
          collections.where(dlpsDeleted: "t").rename(uniqueIdentifier: :id, commonName: :name)
        end

        private

        def collections
          super
        end
      end
    end
  end
end
