module Lauth
  module Persistence
    module Relations
      class Locations < ROM::Relation[:sql]
        schema(:aa_coll_obj, infer: true, as: :locations) do
          associations do
            belongs_to :aa_coll, as: :collection, relation: :collections, foreign_key: :coll
          end
        end

        struct_namespace Entities
        auto_struct true
      end
    end
  end
end
