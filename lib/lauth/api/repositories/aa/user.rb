module Lauth
  module API
    module Repositories
      module AA
        class User < ::ROM::Repository[:users]
          commands :create, update: :by_pk, delete: :by_pk

          struct_namespace Lauth::API::ROM::Entities
          auto_struct true

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
end
