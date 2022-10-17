module Lauth
  module API
    module ROM
      module Relations
        class Collections < ::ROM::Relation[:sql]
          schema(:aa_coll, infer: true, as: :collections) do
            attribute :description, Types::String.default("description".freeze)
            attribute :dlpsSource, Types::String.default("source".freeze)
            attribute :dlpsAuthenMethod, Types::String.default("any".freeze)
            attribute :dlpsAuthzType, Types::String.default("n".freeze)
            attribute :dlpsPartlyPublic, Types::String.default("t".freeze)
          end

          struct_namespace Entities
          auto_struct true
        end
      end
    end
  end
end
