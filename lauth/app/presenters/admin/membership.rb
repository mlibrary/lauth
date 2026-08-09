# frozen_string_literal: true

module Lauth
  module Presenters
    module Admin
      module Membership
        module_function

        def call(membership)
          membership.to_h.slice(:userid, :inst, :lastModifiedTime, :dlpsDeleted)
        end
      end
    end
  end
end
