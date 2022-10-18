module Lauth
  module API
    module Repositories
      class Network < ::ROM::Repository[:networks]
        # commands :create, update: :by_pk, delete: :by_pk

        struct_namespace Lauth::API::ROM::Entities
        auto_struct true

        def include?(ip)
          undeleted_networks.where { (dlpsAddressStart <= ip.to_u32) & (dlpsAddressEnd >= ip.to_u32) }
        end

        def index
          undeleted_networks
        end

        def create(document)
          id = document["data"]["id"]
          network = undeleted_networks.where(uniqueIdentifier: id).one
          return nil if network

          ip_address = IPAddress.parse document["data"]["attributes"]["cidr"]
          return nil unless ip_address

          cidr = "0.0.0.0/0"
          minimum = 0
          maximum = 0xFFFFFFFF
          case ip_address.prefix
          when 32
            cidr = ip_address.to_string
            minimum = maximum = ip_address.to_u32
          when 31
            cidr = ip_address.first.to_string
            minimum = ip_address.first.to_u32
            maximum = ip_address.last.to_u32
          else
            cidr = ip_address.network.to_string
            minimum = ip_address.network.to_u32
            maximum = ip_address.broadcast.to_u32
          end

          document["data"]["attributes"]["minimum"] = minimum
          document["data"]["attributes"]["maximum"] = maximum
          document["data"]["attributes"]["cidr"] = cidr

          if deleted_networks.where(uniqueIdentifier: id).one
            deleted_networks.where(uniqueIdentifier: id).changeset(Lauth::API::ROM::Changesets::NetworkUpdate, document).commit
          else
            undeleted_networks.changeset(Lauth::API::ROM::Changesets::NetworkCreate, document).commit
          end

          undeleted_networks.where(uniqueIdentifier: id).one
        rescue => _e
          nil
        end

        def read(id)
          undeleted_networks.where(uniqueIdentifier: id).one
        end

        def update(document)
          id = document["data"]["id"]
          network = deleted_networks.where(uniqueIdentifier: id).one
          return nil if network

          ip_address = IPAddress.parse document["data"]["attributes"]["cidr"]
          return nil unless ip_address

          cidr = "0.0.0.0/0"
          minimum = 0
          maximum = 0xFFFFFFFF
          case ip_address.prefix
          when 32
            cidr = ip_address.to_string
            minimum = maximum = ip_address.to_u32
          when 31
            cidr = ip_address.first.to_string
            minimum = ip_address.first.to_u32
            maximum = ip_address.last.to_u32
          else
            cidr = ip_address.network.to_string
            minimum = ip_address.network.to_u32
            maximum = ip_address.broadcast.to_u32
          end

          document["data"]["attributes"]["minimum"] = minimum
          document["data"]["attributes"]["maximum"] = maximum
          document["data"]["attributes"]["cidr"] = cidr

          if undeleted_networks.where(uniqueIdentifier: id).one
            undeleted_networks.where(uniqueIdentifier: id).changeset(Lauth::API::ROM::Changesets::NetworkUpdate, document).commit
            undeleted_networks.where(uniqueIdentifier: id).one
          end
        rescue => _e
          nil
        end

        def delete(id)
          network = read(id)
          undeleted_networks.where(uniqueIdentifier: id).update(dlpsDeleted: "t") if network
          network
        end

        protected

        def all_networks
          networks.rename(uniqueIdentifier: :id, dlpsCIDRAddress: :cidr, dlpsAccessSwitch: :access, dlpsAddressStart: :minimum, dlpsAddressEnd: :maximum)
        end

        def undeleted_networks
          networks.where(dlpsDeleted: "f").rename(uniqueIdentifier: :id, dlpsCIDRAddress: :cidr, dlpsAccessSwitch: :access, dlpsAddressStart: :minimum, dlpsAddressEnd: :maximum)
        end

        def deleted_networks
          networks.where(dlpsDeleted: "t").rename(uniqueIdentifier: :id, dlpsCIDRAddress: :cidr, dlpsAccessSwitch: :access, dlpsAddressStart: :minimum, dlpsAddressEnd: :maximum)
        end

        private

        def networks
          super
        end
      end
    end
  end
end
