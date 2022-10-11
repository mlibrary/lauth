module Lauth
  module API
    module Factories
      Factory.define(:institution, struct_namespace: Lauth::API::ROM::Entities) do |f|
        f.sequence(:uniqueIdentifier) { |n| n }
        f.sequence(:organizationName) { |n| "Name#{n}" }
        f.manager 0
        f.lastModifiedTime Time.now
        f.lastModifiedBy "root"
        f.dlpsDeleted "f"
      end
    end
  end
end
