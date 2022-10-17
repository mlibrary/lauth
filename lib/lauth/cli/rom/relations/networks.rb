module Lauth
  module CLI
    module ROM
      module Relations
        class Networks < ::ROM::Relation[:http]
          schema(:networks) do
            attribute :id, Types::Integer
            attribute :access, Types::String
            attribute :cidr, Types::String
          end

          struct_namespace Lauth::CLI::ROM::Entities
          auto_struct true

          def by_id(id)
            append_path(id)
          end
        end
      end
    end
  end
end
