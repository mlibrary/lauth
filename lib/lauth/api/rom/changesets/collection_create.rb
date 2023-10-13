module Lauth
  module API
    module ROM
      module Changesets
        class CollectionCreate < ::ROM::Changeset::Create
          map do
            deep_symbolize_keys
            unwrap :data
            unwrap :attributes
            reject_keys [:type]
            rename_keys id: :uniqueIdentifier, name: :commonName
            deep_merge lastModifiedTime: Time.now
          end
        end
      end
    end
  end
end
