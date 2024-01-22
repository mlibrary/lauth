module Lauth
  module Fab
    class Collection< ROM::Repository[:collections]
      include Deps[container: "persistence.rom"]
      struct_namespace Lauth
      commands :create

      class << self
        def create(**args)
          new.create(**default.merge(args))
        end

        def default
          name = Faker::Creature::Animal.unique.name
          {
            uniqueIdentifier: "id_#{name}",
            commonName: name,
            manager: 0,
            dlpsAuthenMethod: "any",
            dlpsAuthzType: "n",
            lastModifiedTime: Time.now,
            lastModifiedBy: "root",
            dlpsDeleted: "f",
            locations: []
          }
        end

      end
    end
  end
end

