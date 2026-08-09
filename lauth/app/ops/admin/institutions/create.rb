# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Institutions
        class Create
          include Deps[institution_repo: "repositories.institution_repo"]

          def call(organization_name:)
            raise ArgumentError, "organizationName is required" unless organization_name.is_a?(String)

            name = organization_name.strip
            raise ArgumentError, "organizationName is required" if name.empty?

            {institution: institution_repo.create(
              organizationName: name,
              lastModifiedTime: Time.now,
              lastModifiedBy: "root",
              dlpsDeleted: "f"
            )}
          end
        end
      end
    end
  end
end
