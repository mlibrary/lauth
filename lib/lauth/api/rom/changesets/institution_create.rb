module Lauth
  module API
    module ROM
      module Changesets
        class InstitutionCreate < ::ROM::Changeset::Create
          map do
            deep_symbolize_keys
            unwrap :data
            unwrap :attributes
            reject_keys [:type]
            rename_keys id: :uniqueIdentifier, name: :organizationName
            copy_keys surname: :givenName
            deep_merge manager: 0,
              lastModifiedTime: Time.now,
              lastModifiedBy: "root",
              dlpsDeleted: "f"
          end
        end
      end
    end
  end
end
