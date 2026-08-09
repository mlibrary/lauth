# frozen_string_literal: true

module Lauth
  module Presenters
    module Admin
      module Collection
        FIELDS = %i[
          uniqueIdentifier commonName description dlpsClass dlpsSource
          dlpsAuthenMethod dlpsAuthzType dlpsPartlyPublic manager
          lastModifiedTime dlpsDeleted
        ].freeze

        module_function

        def call(collection)
          collection.to_h.slice(*FIELDS)
        end

        def summary(collection)
          collection.to_h.slice(:uniqueIdentifier)
        end
      end
    end
  end
end
