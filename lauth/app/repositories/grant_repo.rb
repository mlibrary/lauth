module Lauth
  module Repositories
    class GrantRepo < ROM::Repository[:grants]
      include Deps[container: "persistence.rom"]
      struct_namespace Lauth

      def find(id)
        grants.where(uniqueIdentifier: id).one
      end

      def for_collection_class(username:, client_ip:, collection_class:)
        ip = client_ip ? IPAddr.new(client_ip).to_i : nil
        smallest_network = networks
          .dataset
          .where { dlpsAddressStart <= ip }
          .where { dlpsAddressEnd >= ip }
          .select_append(Sequel.as(Sequel.expr { dlpsAddressEnd - dlpsAddressStart }, :block_size))
          .order(Sequel.asc(:block_size)).limit(1)

        ds = grants
          .dataset
          .join(collections.name.dataset, uniqueIdentifier: :coll)
          .left_join(users.name.dataset, userid: grants[:userid])
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
        ip = client_ip ? IPAddr.new(client_ip).to_i : nil
        smallest_network = networks
          .dataset
          .where { dlpsAddressStart <= ip }
          .where { dlpsAddressEnd >= ip }
          .select_append(Sequel.as(Sequel.expr { dlpsAddressEnd - dlpsAddressStart }, :block_size))
          .order(Sequel.asc(:block_size)).limit(1)

        ds = grants
          .dataset
          .join(collections.name.dataset, uniqueIdentifier: :coll)
          .join(locations.name.dataset, coll: :uniqueIdentifier)
          .left_join(users.name.dataset, userid: grants[:userid])
          .left_join(institution_memberships.name.dataset, inst: grants[:inst])
          .left_join(group_memberships.name.dataset, user_grp: grants[:user_grp])
          .left_join(Sequel.as(smallest_network, :smallest), inst: grants[:inst])
          .where(Sequel.ilike(uri, locations[:dlpsPath]))
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
        rel.combine(:user, collections: :locations, institutions: {institution_memberships: :users}).to_a
      end
    end
  end
end
