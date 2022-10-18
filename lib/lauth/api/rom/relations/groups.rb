module Lauth
  module API
    module ROM
      module Relations
        class Groups < ::ROM::Relation[:sql]
          schema(:aa_user_grp, infer: true, as: :groups)

          struct_namespace Entities
          auto_struct true
        end
      end
    end
  end
end
