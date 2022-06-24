module Lauth
  module Repositories
    class Client < ROM::Repository[:clients]
      struct_namespace Lauth::Entities
      auto_struct true
      commands :create
    end
  end
end
