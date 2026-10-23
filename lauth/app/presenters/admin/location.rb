# frozen_string_literal: true

module Lauth
  module Presenters
    module Admin
      module Location
        FIELDS = %i[coll dlpsPath dlpsServer lastModifiedTime dlpsDeleted].freeze

        module_function

        def call(location)
          location.to_h.slice(*FIELDS)
        end
      end
    end
  end
end
