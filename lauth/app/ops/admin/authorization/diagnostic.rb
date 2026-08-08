# frozen_string_literal: true

require "ipaddr"

module Lauth
  module Ops
    module Admin
      module Authorization
        class Diagnostic
          include Deps[
            collection_repo: "repositories.collection_repo",
            grant_repo: "repositories.grant_repo"
          ]

          def call(ip:, userid:, collection:)
            raise ArgumentError, "ip, userid, and collection are required" if [ip, userid, collection].any? { |value| !value.is_a?(String) || value.empty? }

            address = IPAddr.new(ip)
            raise ArgumentError, "ip must be an IPv4 address" unless address.ipv4?

            target = collection_repo.find(collection)
            raise NotFound, "collection not found" unless target

            if target.dlpsAuthzType == "d"
              grants = grant_repo.for_collection_class(
                username: userid,
                client_ip: ip,
                collection_class: target.dlpsClass
              )
              authorized = grants.any? { |grant| grant.coll == collection }
            else
              authorized = grant_repo.for(
                username: userid,
                collection: target,
                client_ip: ip
              ).any?
            end

            {
              authorized: authorized,
              authorizedCollection: authorized ? collection : nil,
              publicCollection: (target.dlpsPartlyPublic == "t") ? collection : nil
            }
          rescue IPAddr::InvalidAddressError
            raise ArgumentError, "ip must be an IPv4 address"
          end

          class NotFound < StandardError; end
        end
      end
    end
  end
end
