# frozen_string_literal: true

module Lauth
  module Presenters
    module Admin
      module Grant
        FIELDS = %i[
          uniqueIdentifier userid user_grp inst coll lastModifiedTime
          lastModifiedBy dlpsExpiryTime dlpsDeleted
        ].freeze

        module_function

        def call(grant)
          grant.to_h.slice(*FIELDS)
        end
      end
    end
  end
end
