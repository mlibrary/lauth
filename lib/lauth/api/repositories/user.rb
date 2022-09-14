require_relative "aa/user"

module Lauth
  module API
    module Repositories
      class User < AA::User
        def index
          undeleted_users
        end

        def create(document)
          id = document["data"]["id"]
          user = undeleted_users.where(userid: id).one
          return nil if user

          if deleted_users.where(userid: id).one
            deleted_users.where(userid: id).changeset(Lauth::API::ROM::Changesets::UserUpdate, document).commit
          else
            undeleted_users.changeset(Lauth::API::ROM::Changesets::UserCreate, document).commit
          end

          undeleted_users.where(userid: id).one
        end

        def read(id)
          undeleted_users.where(userid: id).one
        end

        def update(document)
          id = document["data"]["id"]
          user = deleted_users.where(userid: id).one
          return nil if user

          if undeleted_users.where(userid: id).one
            undeleted_users.where(userid: id).changeset(Lauth::API::ROM::Changesets::UserUpdate, document).commit
          end

          undeleted_users.where(userid: id).one
        end

        def delete(id)
          user = read(id)
          undeleted_users.where(userid: id).update(dlpsDeleted: "t") if user
          user
        end
      end
    end
  end
end
