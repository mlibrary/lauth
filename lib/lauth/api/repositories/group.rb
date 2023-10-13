module Lauth
  module API
    module Repositories
      class Group < ::ROM::Repository[:groups]
        # commands :create, update: :by_pk, delete: :by_pk

        struct_namespace Lauth::API::ROM::Entities
        auto_struct true

        def index
          undeleted_groups
        end

        def create(document)
          id = document["data"]["id"]
          group = undeleted_groups.where(uniqueIdentifier: id).one
          return nil if group

          if deleted_groups.where(uniqueIdentifier: id).one
            deleted_groups.where(uniqueIdentifier: id).changeset(Lauth::API::ROM::Changesets::GroupUpdate, document).commit
          else
            undeleted_groups.changeset(Lauth::API::ROM::Changesets::GroupCreate, document).commit
          end

          undeleted_groups.where(uniqueIdentifier: id).one
        end

        def read(id)
          undeleted_groups.where(uniqueIdentifier: id).one
        end

        def update(document)
          id = document["data"]["id"]
          group = deleted_groups.where(uniqueIdentifier: id).one
          return nil if group

          if undeleted_groups.where(uniqueIdentifier: id).one
            undeleted_groups.where(uniqueIdentifier: id).changeset(Lauth::API::ROM::Changesets::GroupUpdate, document).commit
          end

          undeleted_groups.where(uniqueIdentifier: id).one
        end

        def delete(id)
          group = read(id)
          undeleted_groups.where(uniqueIdentifier: id).update(dlpsDeleted: "t") if group
          group
        end

        protected

        def all_groups
          groups.rename(uniqueIdentifier: :id, commonName: :name)
        end

        def undeleted_groups
          groups.where(dlpsDeleted: "f").rename(uniqueIdentifier: :id, commonName: :name)
        end

        def deleted_groups
          groups.where(dlpsDeleted: "t").rename(uniqueIdentifier: :id, commonName: :name)
        end

        private

        def groups
          super
        end
      end
    end
  end
end
