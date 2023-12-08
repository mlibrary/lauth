module Lauth
  module Persistence
    module Relations
      class InstitutionMemberships < ROM::Relation[:sql]
        schema(:aa_is_member_of_inst, infer: true, as: :institution_memberships) do
          # attribute :lastModifiedTime, Types::Time.default { Time.now }
          attribute :lastModifiedBy, Types::String.default("root".freeze)
          # attribute :dlpsExpiryTime, Types::Time.default { Time.now }
          attribute :dlpsDeleted, Types::String.default("f".freeze)

          associations do
            belongs_to :user, foreign_key: :userid
            belongs_to :institution, foreign_key: :inst
          end
        end

        struct_namespace Lauth
        auto_struct true
      end
    end
  end
end
