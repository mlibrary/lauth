module Lauth
  module CLI
    module Repositories
      class Group < ::ROM::Repository[:groups]
        struct_namespace Lauth::CLI::ROM::Entities
        auto_struct true

        def index(opts = {})
          groups
        end

        def create(id, attributes)
          attributes[:id] = id
          groups.command(:create).call(attributes)
        end

        def read(id)
          groups.by_id(id)
        end

        def update(id, attributes)
          attributes[:id] = id
          groups.by_id(id).command(:update).call(attributes)
        end

        def delete(id)
          groups.by_id(id).command(:delete).call
        end

        private

        def groups
          super
        end
      end
    end
  end
end
