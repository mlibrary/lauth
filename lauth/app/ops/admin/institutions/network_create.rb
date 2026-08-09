# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Institutions
        class NetworkCreate
          include Deps[
            institution_repo: "repositories.institution_repo",
            network_repo: "repositories.network_repo"
          ]

          def call(institution_id:, cidrs:, access_switch: nil)
            raise NotFound, "institution not found" unless institution_repo.find(institution_id)
            raise ArgumentError, "cidrs must be a non-empty array" unless cidrs.is_a?(Array) && !cidrs.empty?

            access_switch ||= "allow"
            raise ArgumentError, "accessSwitch must be allow or deny" unless %w[allow deny].include?(access_switch)

            parsed = cidrs.map { |cidr| Lauth::IPv4CIDR.parse(cidr) }
            raise ArgumentError, "cidrs must not contain duplicates" unless parsed.map(&:to_s).uniq.length == parsed.length

            {networks: network_repo.create_batch(parsed.map { |cidr|
              {
                dlpsCIDRAddress: cidr.to_s,
                dlpsAddressStart: cidr.start,
                dlpsAddressEnd: cidr.end,
                dlpsAccessSwitch: access_switch,
                inst: institution_id,
                lastModifiedTime: Time.now,
                lastModifiedBy: "root",
                dlpsDeleted: "f"
              }
            })}
          end

          class NotFound < StandardError; end
        end
      end
    end
  end
end
