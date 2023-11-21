module Lauth
  module Persistence
    module Repositories
      class GrantRepo < ROM::Repository[:grants]
        include Deps[container: "persistence.rom"]
        struct_namespace Entities

        def find(id)
          grants.where(uniqueIdentifier: id).one
        end

        def for_uri(uri)
          grants.combine(collection: :locations)
        end
      end
    end
  end
end
