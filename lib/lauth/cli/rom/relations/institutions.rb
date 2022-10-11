module Lauth
  module CLI
    module ROM
      module Relations
        class Institutions < ::ROM::Relation[:http]
          schema(:institutions) do
            attribute :id, Types::Integer
            attribute :name, Types::String
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
