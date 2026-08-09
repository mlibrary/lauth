# frozen_string_literal: true

module Lauth
  module Presenters
    module Admin
      module Network
        FIELDS = %i[
          uniqueIdentifier dlpsDNSName dlpsCIDRAddress dlpsAddressStart
          dlpsAddressEnd dlpsAccessSwitch inst lastModifiedTime dlpsDeleted
        ].freeze

        module_function

        def call(network)
          network.to_h.slice(*FIELDS)
        end
      end
    end
  end
end
