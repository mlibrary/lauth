module Lauth
  module API
    module Repositories
      module AA
        class User < ::ROM::Repository[:users]
          commands :create, update: :by_pk, delete: :by_pk

          struct_namespace Lauth::API::ROM::Entities
          auto_struct true
        end
      end
    end
  end
end
