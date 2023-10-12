module Lauth
  module API
    module Repositories
      class Location < ::ROM::Repository[:locations]
        struct_namespace Lauth::API::ROM::Entities
        auto_struct true
      end
    end
  end
end
