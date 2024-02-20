module Lauth
  module Repositories
    class CollectionRepo < ROM::Repository[:collections]
      include Deps[container: "persistence.rom"]
      struct_namespace Lauth

      # Find a collection via its uri location, specifically the dlpsPath.
      # This prefers the "most specific" location. We define that here as
      # the path with the deepest nesting, and in case of a tie we then prefer
      # whichever path is longest. I.e. the path /foo/bar/baz% is more specific
      # than /foo/bar/b%.
      # There is an assumption that all dlpsPath values end in the SQL wildcard %.
      # @param uri [String]
      # @return [Collection]
      def find_by_uri(uri)
        dataset = collections
          .dataset
          .where(collections[:dlpsDeleted].is("f"))
          .join(locations.name.dataset, coll: :uniqueIdentifier, dlpsDeleted: "f")
          .where(Sequel.ilike(uri, locations[:dlpsPath]))
          .select_append(Sequel.as( # count the slashes
            Sequel.expr {
              char_length(:dlpsPath) - char_length(replace(:dlpsPath, '/', ''))
            },
            :path_depth
          ))
          .order(
            Sequel.desc(:path_depth),
            Sequel.desc(Sequel.expr { length(:dlpsPath) } )
          )
        collections.class.new(dataset).to_a.first
      end

      def public_in_class(collection_class)
        collections.where(dlpsPartlyPublic: "t", dlpsClass: collection_class, dlpsDeleted: "f").to_a
      end
    end
  end
end
