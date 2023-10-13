module Lauth
  module API
    module ROM
      module Relations
        class Networks < ::ROM::Relation[:sql]
          schema(:aa_network, infer: true, as: :networks) do
            # attribute :uniqueIdentifier, Types::Integer.default { AutoIncrement.id }
            attribute :dlpsDNSName, Types::String.default("www.unknown.dns".freeze)
            # attribute :dlpsCIDRAddress, Types::String
            attribute :dlpsAddressStart, Types::Integer.default(0)
            attribute :dlpsAddressEnd, Types::Integer.default(0xFFFFFFFF)
            attribute :dlpsAccessSwitch, Types::String.default("allow".freeze)
            # attribute :coll, Types::String.default("".freeze)
            # attribute :inst, Types::Integer.default(0)
            # attribute :lastModifiedTime, Types::Time.default { Time.now }
            attribute :lastModifiedBy, Types::String.default("root".freeze)
            attribute :dlpsDeleted, Types::String.default("f".freeze)
          end

          struct_namespace Entities
          auto_struct true
        end
      end
    end
  end
end
