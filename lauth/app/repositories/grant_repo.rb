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
          .join(collections.name.dataset, uniqueIdentifier: :coll)
          .join(locations.name.dataset, coll: :uniqueIdentifier)
          .left_join(users.name.dataset, userid: grants[:userid])
          .left_join(institution_memberships.name.dataset, inst: grants[:inst])
          .where(Sequel.ilike(uri, locations[:dlpsPath]))
          .where(
            Sequel.|(
              Sequel.&(
                Sequel.~(users[:userid] => nil),
                {users[:userid] => username}
              ),
              Sequel.&(
                Sequel.~(institution_memberships[:userid] => nil),
                {institution_memberships[:userid] => username}
              )
            )
          )

        rel = grants.class.new(ds)
        rel.combine(:user, collections: :locations, institutions: {institution_memberships: :users}).to_a
      end

      def for_uri(uri)
        ds = grants
          .dataset
          .join(collections.name.dataset, uniqueIdentifier: :coll)
          .join(locations.name.dataset, coll: :uniqueIdentifier)
          .where(Sequel.ilike(uri, locations[:dlpsPath]))

        rel = grants.class.new(ds)
        rel.combine(:user, collection: :locations).to_a
      end
    end
  end
end
