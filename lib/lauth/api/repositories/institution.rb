module Lauth
  module API
    module Repositories
      class Institution < ::ROM::Repository[:institutions]
        # commands :create, update: :by_pk, delete: :by_pk

        struct_namespace Lauth::API::ROM::Entities
        auto_struct true

        def index
          undeleted_institutions
        end

        def create(document)
          id = document["data"]["id"]
          institution = undeleted_institutions.where(uniqueIdentifier: id).one
          return nil if institution

          if deleted_institutions.where(uniqueIdentifier: id).one
            deleted_institutions.where(uniqueIdentifier: id).changeset(Lauth::API::ROM::Changesets::InstitutionUpdate, document).commit
          else
            undeleted_institutions.changeset(Lauth::API::ROM::Changesets::InstitutionCreate, document).commit
          end

          undeleted_institutions.where(uniqueIdentifier: id).one
        end

        def read(id)
          undeleted_institutions.where(uniqueIdentifier: id).one
        end

        def update(document)
          id = document["data"]["id"]
          institution = deleted_institutions.where(uniqueIdentifier: id).one
          return nil if institution

          if undeleted_institutions.where(uniqueIdentifier: id).one
            undeleted_institutions.where(uniqueIdentifier: id).changeset(Lauth::API::ROM::Changesets::InstitutionUpdate, document).commit
          end

          undeleted_institutions.where(uniqueIdentifier: id).one
        end

        def delete(id)
          institution = read(id)
          undeleted_institutions.where(uniqueIdentifier: id).update(dlpsDeleted: "t") if institution
          institution
        end

        protected

        def all_institutions
          institutions.rename(uniqueIdentifier: :id, organizationName: :name)
        end

        def undeleted_institutions
          institutions.where(dlpsDeleted: "f").rename(uniqueIdentifier: :id, organizationName: :name)
        end

        def deleted_institutions
          institutions.where(dlpsDeleted: "t").rename(uniqueIdentifier: :id, organizationName: :name)
        end

        private

        def institutions
          super
        end
      end
    end
  end
end
