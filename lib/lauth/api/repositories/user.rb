module Lauth
  module API
    module Repositories
      class User < ::ROM::Repository[:users]
        commands :create, update: :by_pk, delete: :by_pk

        struct_namespace Lauth::API::ROM::Entities
        auto_struct true

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

        protected

        def all_users
          users.rename(userid: :id, userPassword: :password, surname: :name)
        end

        def undeleted_users
          users.where(dlpsDeleted: "f").rename(userid: :id, userPassword: :password, surname: :name)
        end

        def deleted_users
          users.where(dlpsDeleted: "t").rename(userid: :id, userPassword: :password, surname: :name)
        end

        private

        def users
          super
        end
      end
    end
  end
end
