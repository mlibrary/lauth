module Lauth
  module Repositories
    class GrantRepo < ROM::Repository[:grants]
      include Deps[container: "persistence.rom"]
      struct_namespace Lauth

      def find(id)
        grants.where(uniqueIdentifier: id).one
      end

      def for_user_and_uri(username, uri)
        ds = grants
          .dataset
          .where(grants[:dlpsDeleted] => "f")
          .join(collections.name.dataset, uniqueIdentifier: :coll, dlpsDeleted: "f")
          .join(locations.name.dataset, coll: :uniqueIdentifier) # , dlpsDeleted: "f") TODO: fix this
          .left_join(users.name.dataset, userid: grants[:userid], dlpsDeleted: "f")
          .left_join(institution_memberships.name.dataset, inst: grants[:inst], dlpsDeleted: "f")
          .left_join(institutions.name.dataset, uniqueIdentifier: institution_memberships[:inst], dlpsDeleted: "f")
          .left_join(Sequel.as(users.name.dataset, :inst_users), userid: institution_memberships[:userid], dlpsDeleted: "f")
          .left_join(group_memberships.name.dataset, user_grp: grants[:user_grp], dlpsDeleted: "f")
          .left_join(groups.name.dataset, uniqueIdentifier: group_memberships[:user_grp], dlpsDeleted: "f")
          .left_join(Sequel.as(users.name.dataset, :group_users), userid: group_memberships[:userid], dlpsDeleted: "f")
          .where(Sequel.ilike(uri, locations[:dlpsPath]))
          .where(
            Sequel.|(
              Sequel.&(
                Sequel.~(users[:userid] => nil),
                {users[:userid] => username}
              ),
              Sequel.&(
                Sequel.~(institutions[:uniqueIdentifier] => nil),
                Sequel.~(Sequel[:inst_users][:userid] => nil),
                {institution_memberships[:userid] => username}
              ),
              Sequel.&(
                Sequel.~(groups[:uniqueIdentifier] => nil),
                Sequel.~(Sequel[:group_users][:userid] => nil),
                {group_memberships[:userid] => username}
              )
            )
          )
        rel = grants.class.new(ds)
        rel.combine(:user, collections: :locations, institutions: {institution_memberships: :users}).to_a
      end
    end
  end
end
