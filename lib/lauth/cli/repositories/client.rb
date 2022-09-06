module Lauth
  module CLI
    module Repositories
      class Client < ::ROM::Repository[:clients]
        struct_namespace Lauth::CLI::ROM::Entities
        auto_struct true
      end
    end
  end
end
