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

        ds = grants
          .dataset
          .where(grants[:dlpsDeleted].is("f"))
          .join(collections.name.dataset, uniqueIdentifier: :coll, dlpsDeleted: "f")
          .left_join(users.name.dataset, userid: grants[:userid], dlpsDeleted: "f")
          .left_join(institution_memberships.name.dataset, inst: grants[:inst])
          .left_join(group_memberships.name.dataset, user_grp: grants[:user_grp])
          .left_join(Sequel.as(smallest_network, :smallest), inst: grants[:inst])
          .where(collections[:dlpsClass] => collection_class)
          .where(
            Sequel.|(
              Sequel.&(
                Sequel.~(users[:userid] => nil),
                {users[:userid] => username}
              ),
              Sequel.&(
                Sequel.~(institution_memberships[:userid] => nil),
                {institution_memberships[:userid] => username}
              ),
              Sequel.&(
                Sequel.~(group_memberships[:userid] => nil),
                {group_memberships[:userid] => username}
              ),
              Sequel.&(
                Sequel.~(Sequel[:smallest][:inst] => nil),
                {Sequel[:smallest][:dlpsAccessSwitch] => "allow"}
              )
            )
          )

        rel = grants.class.new(ds)
        rel.to_a
      end

      def for(username:, uri:, client_ip: nil)
        smallest_network = smallest_network_for_ip(client_ip)

        ds = grants
          .dataset
          .where(grants[:dlpsDeleted].is("f"))
          .join(collections.name.dataset, uniqueIdentifier: :coll, dlpsDeleted: "f")
          .join(locations.name.dataset, coll: :uniqueIdentifier, dlpsDeleted: "f")
          .left_join(users.name.dataset, userid: grants[:userid], dlpsDeleted: "f")
          .left_join(institutions.name.dataset, uniqueIdentifier: grants[:inst], dlpsDeleted: "f")
          .left_join(institution_memberships.name.dataset, inst: :uniqueIdentifier, dlpsDeleted: "f")
          .left_join(Sequel.as(users.name.dataset, :inst_users), userid: :userid, dlpsDeleted: "f")
          .left_join(groups.name.dataset, uniqueIdentifier: grants[:user_grp], dlpsDeleted: "f")
          .left_join(group_memberships.name.dataset, user_grp: :uniqueIdentifier, dlpsDeleted: "f")
          .left_join(Sequel.as(users.name.dataset, :group_users), userid: :userid, dlpsDeleted: "f")
          .left_join(Sequel.as(smallest_network, :smallest), inst: institutions[:uniqueIdentifier])
          .where(Sequel.ilike(uri, locations[:dlpsPath]))
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

        rel = grants.class.new(ds)
        rel.combine(:user, collections: :locations, institutions: {institution_memberships: :users}).to_a
      end

      private

      def smallest_network_for_ip(client_ip)
        ip = client_ip ? IPAddr.new(client_ip).to_i : nil
        smallest_network = networks
          .dataset
          .where(dlpsDeleted: "f")
          .where { dlpsAddressStart <= ip }
          .where { dlpsAddressEnd >= ip }
          .select_append(Sequel.as(Sequel.expr { dlpsAddressEnd - dlpsAddressStart }, :block_size))
          .order(Sequel.asc(:block_size)).limit(1)
      end
    end
  end
end
