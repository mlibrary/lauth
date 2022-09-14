module Lauth
  module CLI
    module Repositories
      class User < ::ROM::Repository[:users]
        struct_namespace Lauth::CLI::ROM::Entities
        auto_struct true

        def index(opts = {})
          users
        end

        def create(id, attributes)
          attributes[:id] = id
          users.command(:create).call(attributes)
        end

        def read(id)
          users.by_id(id)
        end

        def update(id, attributes)
          attributes[:id] = id
          users.by_id(id).command(:update).call(attributes)
        end

        def delete(id)
          users.by_id(id).command(:delete).call
        end

        private

        def users
          super
        end
      end
    end
  end
end
