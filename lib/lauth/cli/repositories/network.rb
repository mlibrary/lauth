module Lauth
  module CLI
    module Repositories
      class Network < ::ROM::Repository[:networks]
        struct_namespace Lauth::CLI::ROM::Entities
        auto_struct true

        def query(ip)
          networks.by_ip(ip)
        end

        def index(opts = {})
          networks
        end

        def create(id, attributes)
          attributes[:id] = id
          networks.command(:create).call(attributes)
        end

        def read(id)
          networks.by_id(id)
        end

        def update(id, attributes)
          attributes[:id] = id
          networks.by_id(id).command(:update).call(attributes)
        end

        def delete(id)
          networks.by_id(id).command(:delete).call
        end

        private

        def networks
          super
        end
      end
    end
  end
end
