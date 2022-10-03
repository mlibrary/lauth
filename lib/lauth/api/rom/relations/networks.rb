module Lauth
  module API
    module ROM
      module Relations
        class Networks < ::ROM::Relation[:sql]
          schema(:aa_network, infer: true, as: :networks) do
            attribute :dlpsAccessSwitch, Types::String.default("allow")
          end

          struct_namespace Entities
          auto_struct true
        end
      end
    end
  end
end
