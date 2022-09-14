module Lauth
  module CLI
    module Repositories
      class Institution < ::ROM::Repository[:institutions]
        struct_namespace Lauth::CLI::ROM::Entities
        auto_struct true

        def index(opts = {})
          institutions
        end

        def create(id, attributes)
          attributes[:id] = id
          institutions.command(:create).call(attributes)
        end

        def read(id)
          institutions.by_id(id)
        end

        def update(id, attributes)
          attributes[:id] = id
          institutions.by_id(id).command(:update).call(attributes)
        end

        def delete(id)
          institutions.by_id(id).command(:delete).call
        end

        private

        def institutions
          super
        end
      end
    end
  end
end
