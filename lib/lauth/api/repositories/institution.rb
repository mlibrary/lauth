require_relative "aa/institution"

module Lauth
  module API
    module Repositories
      class Institution < AA::Institution
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
      end
    end
  end
end
