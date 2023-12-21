module Lauth
  module Persistence
    module Relations
      # +------------------+------------------+------+-----+---------+----------------+
      # | Field            | Type             | Null | Key | Default | Extra          |
      # +------------------+------------------+------+-----+---------+----------------+
      # | uniqueIdentifier | int(11)          | NO   | PRI | NULL    | auto_increment |
      # | dlpsDNSName      | varchar(128)     | YES  |     | NULL    |                |
      # | dlpsCIDRAddress  | varchar(18)      | YES  |     | NULL    |                |
      # | dlpsAddressStart | int(10) unsigned | YES  | MUL | NULL    |                |
      # | dlpsAddressEnd   | int(10) unsigned | YES  | MUL | NULL    |                |
      # | dlpsAccessSwitch | varchar(5)       | NO   |     | NULL    |                |
      # | coll             | varchar(32)      | YES  | MUL | NULL    |                |
      # | inst             | int(11)          | YES  | MUL | NULL    |                |
      # | lastModifiedTime | timestamp        | NO   |     | NULL    |                |
      # | lastModifiedBy   | varchar(64)      | NO   | MUL | NULL    |                |
      # | dlpsDeleted      | char(1)          | NO   |     | NULL    |                |
      # +------------------+------------------+------+-----+---------+----------------+
      class Networks < ROM::Relation[:sql]
        schema(:aa_network, infer: true, as: :networks) do
          attribute :lastModifiedBy, Types::String.default("root".freeze)
          attribute :dlpsDeleted, Types::String.default("f".freeze)

          associations do
            belongs_to :collection, foreign_key: :coll
            belongs_to :institution, foreign_key: :inst
          end
        end

        struct_namespace Lauth
        auto_struct true
      end
    end
  end
end
