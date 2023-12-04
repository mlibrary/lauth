module Lauth
  module Repositories
    class GrantRepo < ROM::Repository[:grants]
      include Deps[container: "persistence.rom"]
      struct_namespace Lauth

      def find(id)
        grants.where(uniqueIdentifier: id).one
      end

      def for_uri(uri)
        ds = grants
          .dataset
          .join(collections.name.dataset, uniqueIdentifier: :coll)
          .join(locations.name.dataset, coll: :uniqueIdentifier)
          .where(Sequel.ilike(uri, locations[:dlpsPath]))

        rel = grants.class.new(ds)
        rel.combine(collection: :locations).to_a
      end
    end
  end
end
