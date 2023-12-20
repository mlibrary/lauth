module Lauth
  module Repositories
    class GrantRepo < ROM::Repository[:grants]
      include Deps[container: "persistence.rom"]
      struct_namespace Lauth

      def find(id)
        grants.where(uniqueIdentifier: id).one
      end

      def for(username:, uri:, client_ip: nil)
        ip = client_ip ? IPAddr.new(client_ip).to_i : nil
        smallest_network = networks
          .dataset
          .where { dlpsAddressStart <= ip }
          .where { dlpsAddressEnd >= ip }
          .select_append(Sequel.as(Sequel.expr { dlpsAddressEnd - dlpsAddressStart }, :block_size))
          .order(Sequel.asc(:block_size)).limit(1)

        ds = grants
          .dataset
          .where(grants[:dlpsDeleted] => "f")
          .join(collections.name.dataset, uniqueIdentifier: :coll, dlpsDeleted: "f")
          .join(locations.name.dataset, coll: :uniqueIdentifier, dlpsDeleted: "f")
          .left_join(users.name.dataset, userid: grants[:userid], dlpsDeleted: "f")
          .left_join(institution_memberships.name.dataset, inst: grants[:inst], dlpsDeleted: "f")
          .left_join(institutions.name.dataset, uniqueIdentifier: institution_memberships[:inst], dlpsDeleted: "f")
          .left_join(Sequel.as(users.name.dataset, :inst_users), userid: institution_memberships[:userid], dlpsDeleted: "f")
          .left_join(group_memberships.name.dataset, user_grp: grants[:user_grp], dlpsDeleted: "f")
          .left_join(groups.name.dataset, uniqueIdentifier: group_memberships[:user_grp], dlpsDeleted: "f")
          .left_join(Sequel.as(users.name.dataset, :group_users), userid: group_memberships[:userid], dlpsDeleted: "f")
          .left_join(Sequel.as(smallest_network, :smallest), inst: grants[:inst])
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
    end
  end
end
