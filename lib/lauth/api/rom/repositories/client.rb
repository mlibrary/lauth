module Lauth
  module API
    module ROM
      module Repositories
        class Client < ::ROM::Repository[:clients]
          commands :create, update: :by_pk, delete: :by_pk

          struct_namespace Lauth::API::ROM::Entities
          auto_struct true
        end
      end
    end
  end
end
