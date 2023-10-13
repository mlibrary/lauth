module Lauth
  module API
    module Factories
      Factory.define(:network, struct_namespace: Lauth::API::ROM::Entities) do |f|
        class_c_base = IPAddress.parse("192.0.0.0/24")
        class_c_base_u32 = class_c_base.to_u32
        f.sequence(:uniqueIdentifier) { |n| n }
        f.sequence(:dlpsCIDRAddress) { |n| IPAddress::IPv4.parse_u32(class_c_base_u32 + n, 24).to_string }
        f.sequence(:dlpsAccessSwitch) { |n| "allow" }
        f.lastModifiedTime Time.now
        f.lastModifiedBy "root"
        f.dlpsDeleted "f"
      end
    end
  end
end
