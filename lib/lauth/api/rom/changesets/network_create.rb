module Lauth
  module API
    module ROM
      module Changesets
        class NetworkCreate < ::ROM::Changeset::Create
          map do
            deep_symbolize_keys
            unwrap :data
            unwrap :attributes
            reject_keys [:type]
            rename_keys id: :uniqueIdentifier, cidr: :dlpsCIDRAddress, access: :dlpsAccessSwitch
            rename_keys minimum: :dlpsAddressStart, maximum: :dlpsAddressEnd
            deep_merge lastModifiedTime: Time.now
          end
        end
      end
    end
  end
end
