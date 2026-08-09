# frozen_string_literal: true

module Lauth
  module Repositories
    class UserRepo < ROM::Repository[:users]
      include Deps[container: "persistence.rom"]

      struct_namespace Lauth

      def find(userid)
        dataset = users
          .dataset
          .where(userid: userid, dlpsDeleted: "f")
        users.class.new(dataset).to_a.first
      end
    end
  end
end
