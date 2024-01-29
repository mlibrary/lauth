module Lauth
  module Repositories
    class CollectionRepo < ROM::Repository[:collections]
      include Deps[container: "persistence.rom"]
      struct_namespace Lauth

      def find_by_uri(uri)
        dataset = collections
          .dataset
          .join(locations.name.dataset, coll: :uniqueIdentifier)
          .where(Sequel.ilike(uri, locations[:dlpsPath]))
        collections.class.new(dataset).to_a.first
      end

      def public_in_class(collection_class)
        collections.where(dlpsPartlyPublic: "t", dlpsClass: collection_class).to_a
      end
    end
  end
end
