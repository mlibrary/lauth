# frozen_string_literal: true

require "ipaddr"

module Lauth
  module Ops
    class Access
      include Deps[
        "repositories.grant_repo",
        "repositories.collection_repo",
        "repositories.group_membership_repo"
      ]

      def call(collection:, user:, client_ip: nil)
        raise ArgumentError, "collection is required" unless collection
        validate_ip!(client_ip) if client_ip

        case collection.dlpsAuthzType
        when "n"
          normal_mode(collection: collection, user: user, client_ip: client_ip)
        when "d"
          delegated_mode(collection: collection, user: user, client_ip: client_ip)
        when "m"
          management_mode(collection: collection, user: user)
        else
          raise ArgumentError,
            "Collection with ID '#{collection.uniqueIdentifier}' has invalid " \
            "Authorization Type '#{collection.dlpsAuthzType}'. It must be 'n' " \
            "or 'd' (for a normal or delegated collection, respectively)."
        end
      end

      private

      def normal_mode(collection:, user:, client_ip:)
        relevant_grants = grant_repo.for(
          username: user,
          collection: collection,
          client_ip: client_ip
        )
        determination = relevant_grants.any? ? "allowed" : "denied"
        Lauth::Access::Result.new(determination: determination)
      end

      def delegated_mode(collection:, user:, client_ip:)
        authorized_ids = grant_repo.for_collection_class(
          username: user,
          client_ip: client_ip,
          collection_class: collection.dlpsClass
        ).map(&:coll)
        public_ids = collection_repo.public_in_class(collection.dlpsClass)
          .map(&:uniqueIdentifier)

        Lauth::Access::Result.new(
          determination: "allowed",
          authorized_collections: authorized_ids,
          public_collections: public_ids - authorized_ids
        )
      end

      def management_mode(collection:, user:)
        authorized_ids = if group_membership_repo.member?(user, collection.manager)
          if collection.manager == 0
            ["All"]
          else
            collection_repo.managed_by(collection.manager).map(&:uniqueIdentifier)
          end
        else
          []
        end

        Lauth::Access::Result.new(
          determination: "allowed",
          authorized_collections: authorized_ids,
          public_collections: []
        )
      end

      def validate_ip!(value)
        address = IPAddr.new(value)
        raise ArgumentError, "ip must be an IPv4 address" unless address.ipv4?
      rescue IPAddr::InvalidAddressError
        raise ArgumentError, "ip must be an IPv4 address"
      end
    end
  end
end
