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
          .join(users.name.dataset, userid: grants[:userid])
          .where(users[:userid] => username)
          .where(Sequel.ilike(uri, locations[:dlpsPath]))

        rel = grants.class.new(ds)
        rel.combine(:user, collection: :locations).to_a
      end

      # FIXME: This is scratch code for getting institutions and memberships worked in.
      #        The real implementation will be integrated into for_user_and_uri because we
      #        don't differentiate by grant type when authorizing; we just have user + uri.
      #        This is fully explicit (all joins and username filtered in the WHERE) and
      #        fully eager (loading all of the associated entities), for the sake of demo
      #        and discussion. It will likely use left joins or unions to find everything
      #        while partitioning the complexity into the three types of grants. Since
      #        loading the associated entities is done by IN clause on IDs, we are not
      #        concerned with the ultimate result set having all of the columns and the
      #        overhead of duplicates. The joins are really only to filter the grants.
      def for_member_and_uri(username, uri)
        ds = grants
          .dataset
          .join(collections.name.dataset, uniqueIdentifier: :coll)
          .join(locations.name.dataset, coll: :uniqueIdentifier)
          .join(institutions.name.dataset, uniqueIdentifier: grants[:inst])
          .join(institution_memberships.name.dataset, inst: :uniqueIdentifier)
          .join(users.name.dataset, userid: :userid)
          .where(Sequel.ilike(uri, locations[:dlpsPath]))
          .where(users[:userid] => username)

        rel = grants.class.new(ds)
        rel.combine(collections: :locations, institutions: {institution_memberships: :users}).to_a
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
