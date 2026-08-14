# frozen_string_literal: true

module Lauth
  module Presenters
    module Admin
      module Institution
        module_function

        def call(institution)
          institution.to_h.slice(:uniqueIdentifier, :organizationName)
        end
      end
    end
  end
end
