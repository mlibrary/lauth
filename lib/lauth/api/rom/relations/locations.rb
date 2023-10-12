module Lauth
  module API
    module ROM
      module Relations
        class Locations < ::ROM::Relation[:sql]
          schema(:aa_coll_obj, infer: true, as: :locations) do
            associations do
              belongs_to :collections
            end
          end

          struct_namespace Entities
          auto_struct true
        end
      end
    end
  end
end
