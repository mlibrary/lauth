module Lauth
  module API
    module Repositories
      class Network < ::ROM::Repository[:networks]
        commands :create, update: :by_pk, delete: :by_pk

        struct_namespace Lauth::API::ROM::Entities
        auto_struct true

        def index
          undeleted_networks
        end

        def create(document)
          id = document["data"]["id"]
          network = undeleted_networks.where(uniqueIdentifier: id).one
          return nil if network

          if deleted_networks.where(uniqueIdentifier: id).one
            deleted_networks.where(uniqueIdentifier: id).changeset(Lauth::API::ROM::Changesets::NetworkUpdate, document).commit
          else
            undeleted_networks.changeset(Lauth::API::ROM::Changesets::NetworkCreate, document).commit
          end

          undeleted_networks.where(uniqueIdentifier: id).one
        end

        def read(id)
          undeleted_networks.where(uniqueIdentifier: id).one
        end

        def update(document)
          id = document["data"]["id"]
          network = deleted_networks.where(uniqueIdentifier: id).one
          return nil if network

          if undeleted_networks.where(uniqueIdentifier: id).one
            undeleted_networks.where(uniqueIdentifier: id).changeset(Lauth::API::ROM::Changesets::NetworkUpdate, document).commit
          end

          undeleted_networks.where(uniqueIdentifier: id).one
        end

        def delete(id)
          network = read(id)
          undeleted_networks.where(uniqueIdentifier: id).update(dlpsDeleted: "t") if network
          network
        end

        protected

        def all_networks
          networks.rename(uniqueIdentifier: :id, dlpsCIDRAddress: :cidr, dlpsAccessSwitch: :access)
        end

        def undeleted_networks
          networks.where(dlpsDeleted: "f").rename(uniqueIdentifier: :id, dlpsCIDRAddress: :cidr, dlpsAccessSwitch: :access)
        end

        def deleted_networks
          networks.where(dlpsDeleted: "t").rename(uniqueIdentifier: :id, dlpsCIDRAddress: :cidr, dlpsAccessSwitch: :access)
        end

        private

        def networks
          super
        end
      end
    end
  end
end
