module Lauth
  module Repositories
    class GrantRepo < ROM::Repository[:grants]
      include Deps[container: "persistence.rom"]
      struct_namespace Lauth

      def find(id)
        grants.where(uniqueIdentifier: id).one
      end

      def for_collection_class(username:, client_ip:, collection_class:)
        smallest_network = smallest_network_for_ip(client_ip)
        ds = base_grants_for(username: username, network: smallest_network)
          .join(collections.name.dataset, uniqueIdentifier: grants[:coll], dlpsDeleted: "f")
          .where(collections[:dlpsClass] => collection_class)

        rel = grants.class.new(ds)
        rel.to_a
      end

      def for(username:, collection:, client_ip: nil)
        return [] unless collection&.dlpsDeleted == "f"

        smallest_network = smallest_network_for_ip(client_ip)
        ds = base_grants_for(username: username, network: smallest_network)
          .where(grants[:coll] => collection.uniqueIdentifier)

        rel = grants.class.new(ds)
        rel.combine(:user, institutions: {institution_memberships: :users}).to_a
      end

      private

      def smallest_network_for_ip(client_ip)
        ip = client_ip ? IPAddr.new(client_ip).to_i : nil
        networks
          .dataset
          .where(dlpsDeleted: "f")
          .where { dlpsAddressStart <= ip }
          .where { dlpsAddressEnd >= ip }
          .select_append(Sequel.as(Sequel.expr { dlpsAddressEnd - dlpsAddressStart }, :block_size))
          .order(Sequel.asc(:block_size)).limit(1)
      end

      def base_grants_for(username:, network:)
        grants
          .dataset
          .where(grants[:dlpsDeleted].is("f"))
          .left_join(users.name.dataset, userid: grants[:userid], dlpsDeleted: "f")
          .left_join(institutions.name.dataset, uniqueIdentifier: grants[:inst], dlpsDeleted: "f")
          .left_join(institution_memberships.name.dataset, inst: :uniqueIdentifier, dlpsDeleted: "f")
          .left_join(Sequel.as(users.name.dataset, :inst_users), userid: :userid, dlpsDeleted: "f")
          .left_join(groups.name.dataset, uniqueIdentifier: grants[:user_grp], dlpsDeleted: "f")
          .left_join(group_memberships.name.dataset, user_grp: :uniqueIdentifier, dlpsDeleted: "f")
          .left_join(Sequel.as(users.name.dataset, :group_users), userid: :userid, dlpsDeleted: "f")
          .left_join(Sequel.as(network, :smallest), inst: institutions[:uniqueIdentifier])
          .where(
            Sequel.|(
              Sequel.&(
                Sequel.~(users[:userid] => nil),
                {users[:userid] => username}
              ),
              Sequel.&(
                Sequel.~(institutions[:uniqueIdentifier] => nil),
                Sequel.~(Sequel[:inst_users][:userid] => nil),
                {institution_memberships[:userid] => username}
              ),
              Sequel.&(
                Sequel.~(groups[:uniqueIdentifier] => nil),
                Sequel.~(Sequel[:group_users][:userid] => nil),
                {group_memberships[:userid] => username}
              ),
              Sequel.&(
                Sequel.~(Sequel[:smallest][:inst] => nil),
                {Sequel[:smallest][:dlpsAccessSwitch] => "allow"}
              )
            )
          )
      end
    end
  end
end
