# frozen_string_literal: true

module Lauth
  module Presenters
    module Admin
      module User
        FIELDS = %i[
          userid givenName surname rfc822Mailbox organizationalUnitName
          localityName stateOrProvinceName postalCode countryName telephoneNumber
          organizationalStatus dlpsCourse manager lastModifiedBy dlpsDeleted
        ].freeze

        module_function

        def call(user)
          user.to_h.slice(*FIELDS)
        end
      end
    end
  end
end
