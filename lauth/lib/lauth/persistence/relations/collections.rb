module Lauth
  module Persistence
    module Relations
      class Collections < ROM::Relation[:sql]
        schema(:aa_coll, infer: true, as: :collections) do
          # attribute :uniqueIdentifier, Types::Integer.default { AutoIncrement.id }
          # attribute :commonName, Types::String
          attribute :description, Types::String.default("description".freeze)
          attribute :dlpsClass, Types::String.default("class".freeze)
          attribute :dlpsSource, Types::String.default("source".freeze)
          attribute :dlpsAuthenMethod, Types::String.default("any".freeze)
          attribute :dlpsAuthzType, Types::String.default("n".freeze)
          attribute :dlpsPartlyPublic, Types::String.default("t".freeze)
          attribute :manager, Types::Integer.default(0)
          # attribute :lastModifiedTime, Types::Time.default { Time.now }
          attribute :lastModifiedBy, Types::String.default("root".freeze)
          attribute :dlpsDeleted, Types::String.default("f".freeze)

          associations do
            has_many :locations, foreign_key: :coll
          end
        end

        struct_namespace Entities
        auto_struct true
      end
    end
  end
end
