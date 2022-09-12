module Lauth
  module CLI
    module Repositories
      class User < ::ROM::Repository[:users]
        struct_namespace Lauth::CLI::ROM::Entities
        auto_struct true
      end
    end
  end
end
