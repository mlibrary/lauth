module Lauth
  module CLI
    module ROM
      module Relations
        class Clients < ::ROM::Relation[:http]
          schema(:clients) do
            attribute :id, Types::Integer
            attribute :name, Types::String
          end

          struct_namespace Lauth::CLI::ROM::Entities
          auto_struct true
        end
      end
    end
  end
end
