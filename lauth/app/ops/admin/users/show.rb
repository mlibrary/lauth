# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Users
        class Show
          include Deps[
            user_repo: "repositories.user_repo",
            institution_membership_repo: "repositories.institution_membership_repo",
            grant_repo: "repositories.grant_repo"
          ]

          def call(userid:)
            user = user_repo.find(userid)
            raise NotFound, "user not found" unless user

            {
              userid: userid,
              user: user,
              memberships: institution_membership_repo.for_user(userid),
              grants: grant_repo.for_user(userid)
            }
          end

          class NotFound < StandardError; end
        end
      end
    end
  end
end
