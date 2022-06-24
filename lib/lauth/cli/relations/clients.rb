module Lauth
  module Cli
    module Relations
      class Clients < ROM::Relation[:http]
        schema(:clients) do
          attribute :id, Types::Integer
          attribute :name, Types::String
        end
      end
    end
  end
end
