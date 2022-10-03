module Lauth
  module API
    module Factories
      Factory.define(:network, struct_namespace: Lauth::API::ROM::Entities) do |f|
        f.sequence(:uniqueIdentifier) { |n| n }
        f.sequence(:dlpsCIDRAddress) { |n| "#{n}/24" }
        f.sequence(:dlpsAccessSwitch) { |n| "allow" }
        f.lastModifiedTime Time.now
        f.lastModifiedBy "root"
        f.dlpsDeleted "f"
      end
    end
  end
end
