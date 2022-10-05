module Lauth
  module API
    module ROM
      module Relations
        class Institutions < ::ROM::Relation[:sql]
          schema(:aa_inst, infer: true, as: :institutions)

          struct_namespace Entities
          auto_struct true
        end
      end
    end
  end
end