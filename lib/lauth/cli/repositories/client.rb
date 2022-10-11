module Lauth
  module CLI
    module Repositories
      class Client < ::ROM::Repository[:clients]
        struct_namespace Lauth::CLI::ROM::Entities
        auto_struct true

        def index(opts = {})
          clients
        end

        def create(attributes)
          clients.command(:create).call(attributes)
        end

        def read(id)
          clients.by_id(id)
        end

        def update(id, attributes)
          attributes[:id] = id
          clients.by_id(id).command(:update).call(attributes)
        end

        def delete(id)
          clients.by_id(id).command(:delete).call
        end

        private

        def clients
          super
        end
      end
    end
  end
end
