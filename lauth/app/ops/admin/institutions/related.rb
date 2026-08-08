# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Institutions
        class Related
          include Deps[
            "repositories.institution_repo",
            "repositories.network_repo",
            "repositories.grant_repo"
          ]

          def networks(institution_id:)
            ensure_institution(institution_id)
            {networks: network_repo.for_institution(institution_id)}
          end

          def grants(institution_id:)
            ensure_institution(institution_id)
            {grants: grant_repo.for_institution(institution_id)}
          end

          private

          def ensure_institution(id)
            raise NotFound, "institution not found" unless institution_repo.find(id)
          end

          class NotFound < StandardError; end
        end
      end
    end
  end
end
