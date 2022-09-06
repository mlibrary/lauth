require_relative "aa/user"

module Lauth
  module API
    module Repositories
      class User < AA::User
        def user(id)
          users.where(userid: id).one
        end

        def users
          super.rename(userid: :id)
        end

        def create
          super
        end

        def update
          super
        end

        def delete
          super
        end
      end
    end
  end
end
