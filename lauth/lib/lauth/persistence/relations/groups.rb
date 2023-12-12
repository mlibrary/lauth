module Lauth
  module Persistence
    module Relations
      class Groups < ROM::Relation[:sql]
        schema(:aa_user_grp, infer: true, as: :groups) do
          # attribute :lastModifiedTime, Types::Time.default { Time.now }
          # attribute :manager, Types::Integer.default(0)
          attribute :lastModifiedBy, Types::String.default("root".freeze)
          attribute :dlpsDeleted, Types::String.default("f".freeze)

          associations do
            has_many :grants, foreign_key: :user_grp
            has_many :group_memberships, foreign_key: :user_grp
          end
        end

        struct_namespace Lauth
        auto_struct true
      end
    end
  end
end
