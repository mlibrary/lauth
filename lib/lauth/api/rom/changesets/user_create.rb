module Lauth
  module API
    module ROM
      module Changesets
        class UserCreate < ::ROM::Changeset::Create
          map do
            deep_symbolize_keys
            unwrap :data
            unwrap :attributes
            reject_keys [:type]
            rename_keys id: :userid, name: :surname
            copy_keys surname: :givenName
            deep_merge dlpsKey: 0,
              userPassword: "password",
              lastModifiedTime: Time.now,
              lastModifiedBy: "root",
              dlpsDeleted: "f"
          end
        end
      end
    end
  end
end
