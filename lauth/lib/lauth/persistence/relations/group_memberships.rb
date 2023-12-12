module Lauth
  module Persistence
    module Relations
      class GroupMemberships < ROM::Relation[:sql]
        schema(:aa_is_member_of_grp, infer: true, as: :group_memberships) do
          # attribute :lastModifiedTime, Types::Time.default { Time.now }
          attribute :lastModifiedBy, Types::String.default("root".freeze)
          attribute :dlpsDeleted, Types::String.default("f".freeze)

          associations do
            belongs_to :user, foreign_key: :userid
            belongs_to :group, foreign_key: :user_grp
          end
        end

        struct_namespace Lauth
        auto_struct true
      end
    end
  end
end
