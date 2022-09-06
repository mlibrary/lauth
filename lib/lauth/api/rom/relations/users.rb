module Lauth
  module API
    module ROM
      module Relations
        class Users < ::ROM::Relation[:sql]
          schema(:aa_user, infer: true, as: :users)

          struct_namespace Entities
          auto_struct true
        end
      end
    end
  end
end
