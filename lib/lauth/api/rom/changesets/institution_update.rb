module Lauth
  module API
    module ROM
      module Changesets
        class InstitutionUpdate < ::ROM::Changeset::Update
          map do
            deep_symbolize_keys
            unwrap :data
            unwrap :attributes
            reject_keys [:type]
            rename_keys id: :uniqueIdentifier, name: :organizationName
            deep_merge lastModifiedTime: Time.now
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
