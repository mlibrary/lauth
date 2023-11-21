module Lauth
  module Persistence
    module Relations
      class Grants < ROM::Relation[:sql]
        schema(:aa_may_access, infer: true, as: :grants) do
          # attribute :uniqueIdentifier, Types::Integer.default { AutoIncrement.id }
          # attribute :userid, Types::String.default("userid".freeze)
          # attribute :user_grp, Types::Integer.default(0)
          # attribute :inst, Types::Integer.default(0)
          # attribute :coll, Types::String.default("coll".freeze)
          # attribute :lastModifiedTime, Types::Time.default { Time.now }
          attribute :lastModifiedBy, Types::String.default("root".freeze)
          # attribute :dlpsExpiryTime, Types::Time.default { Time.now }
          attribute :dlpsDeleted, Types::String.default("f".freeze)

          associations do
            belongs_to :user, foreign_key: :userid
            belongs_to :collection, foreign_key: :coll
          end
        end

        struct_namespace Entities
        auto_struct true
      end
    end
  end
end
