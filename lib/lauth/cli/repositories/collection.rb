module Lauth
  module CLI
    module Repositories
      class Collection < ::ROM::Repository[:collections]
        struct_namespace Lauth::CLI::ROM::Entities
        auto_struct true

        def index(opts = {})
          collections
        end

        def create(id, attributes)
          attributes[:id] = id
          collections.command(:create).call(attributes)
        end

        def read(id)
          collections.by_id(id)
        end

        def update(id, attributes)
          attributes[:id] = id
          collections.by_id(id).command(:update).call(attributes)
        end

        def delete(id)
          collections.by_id(id).command(:delete).call
        end

        private

        def collections
          super
        end
      end
    end
  end
end
