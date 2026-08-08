# frozen_string_literal: true

module Lauth
  module Repositories
    class UserRepo < ROM::Repository[:users]
      include Deps[container: "persistence.rom"]

      struct_namespace Lauth

      def find(userid)
        users
          .dataset
          .where(userid: userid, dlpsDeleted: "f")
          .select(:userid, :givenName, :surname, :rfc822Mailbox, :organizationalUnitName,
            :localityName, :stateOrProvinceName, :postalCode, :countryName,
            :telephoneNumber, :organizationalStatus, :dlpsCourse, :manager,
            :lastModifiedBy, :dlpsDeleted)
          .first
      end
    end
  end
end
