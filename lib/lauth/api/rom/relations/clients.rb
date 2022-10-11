module Lauth
  module API
    module ROM
      module Relations
        class Clients < ::ROM::Relation[:sql]
          schema(:clients, infer: true)

          struct_namespace Entities
          auto_struct true
        end
      end
    end
  end
end
