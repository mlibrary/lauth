module Lauth
  module Persistence
    module Relations
      class Locations < ROM::Relation[:sql]
        schema(:aa_coll_obj, infer: true, as: :locations) do
          associations do
            belongs_to :collection, foreign_key: :coll
          end
        end

        struct_namespace Lauth
        auto_struct true
      end
    end
  end
end
