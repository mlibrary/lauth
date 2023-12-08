module Lauth
  module Persistence
    module Relations
      class Institutions < ROM::Relation[:sql]
        schema(:aa_inst, infer: true, as: :institutions) do
          # attribute :lastModifiedTime, Types::Time.default { Time.now }
          attribute :lastModifiedBy, Types::String.default("root".freeze)
          # attribute :dlpsExpiryTime, Types::Time.default { Time.now }
          attribute :dlpsDeleted, Types::String.default("f".freeze)

          associations do
            has_many :grants, foreign_key: :inst
            has_many :institution_memberships, foreign_key: :inst
          end
        end

        struct_namespace Lauth
        auto_struct true
      end
    end
  end
end
