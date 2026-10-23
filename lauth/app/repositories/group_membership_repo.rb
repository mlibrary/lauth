# frozen_string_literal: true

module Lauth
  module Repositories
    class GroupMembershipRepo < ROM::Repository[:group_memberships]
      include Deps[container: "persistence.rom"]

      def member?(userid, group_id)
        group_memberships.dataset
          .where(userid: userid, user_grp: group_id, dlpsDeleted: "f")
          .count.positive?
      end
    end
  end
end
