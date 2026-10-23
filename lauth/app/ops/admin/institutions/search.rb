# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Institutions
        class Search
          include Deps[institution_repo: "repositories.institution_repo"]

          def call(organization_name:)
            {institutions: institution_repo.search_by_organization_name(organization_name)}
          end
        end
      end
    end
  end
end
