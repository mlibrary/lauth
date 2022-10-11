module Lauth
  module API
    module ROM
      module Changesets
        class UserUpdate < ::ROM::Changeset::Update
          map do
            deep_symbolize_keys
            unwrap :data
            unwrap :attributes
            reject_keys [:type]
            rename_keys id: :userid, name: :surname
            copy_keys surname: :givenName
            deep_merge lastModifiedTime: Time.now,
              lastModifiedBy: "root",
              dlpsDeleted: "f"
          end

          def clean?
            false
          end

          def diff?
            true
          end
        end
      end
    end
  end
end
