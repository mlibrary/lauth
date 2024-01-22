module Lauth
  module Persistence
    module Relations
      # +------------------+--------------+------+-----+---------+-------+
      # | Field            | Type         | Null | Key | Default | Extra |
      # +------------------+--------------+------+-----+---------+-------+
      # | uniqueIdentifier | varchar(32)  | NO   | PRI | NULL    |       |
      # | commonName       | varchar(128) | NO   |     | NULL    |       |
      # | description      | varchar(128) | NO   |     | NULL    |       |
      # | dlpsClass        | varchar(10)  | YES  |     | NULL    |       |
      # | dlpsSource       | varchar(128) | NO   |     | NULL    |       |
      # | dlpsAuthenMethod | varchar(3)   | NO   |     | NULL    |       |
      # | dlpsAuthzType    | char(1)      | NO   |     | NULL    |       |
      # | dlpsPartlyPublic | char(1)      | NO   |     | NULL    |       |
      # | manager          | int(11)      | YES  |     | NULL    |       |
      # | lastModifiedTime | timestamp    | NO   |     | NULL    |       |
      # | lastModifiedBy   | varchar(64)  | NO   |     | NULL    |       |
      # | dlpsDeleted      | char(1)      | NO   |     | NULL    |       |
      # +------------------+--------------+------+-----+---------+-------+
      class Collections < ROM::Relation[:sql]
        schema(:aa_coll, infer: false, as: :collections) do
          attribute :uniqueIdentifier, Types::String.meta(primary_key: true)
          attribute :commonName, Types::String.default("commonName".freeze)
          attribute :description, Types::String.default("description".freeze)
          attribute :dlpsClass, Types::String.default("class".freeze)
          attribute :dlpsSource, Types::String.default("source".freeze)
          attribute :dlpsAuthenMethod, Types::String.default("any".freeze)
          attribute :dlpsAuthzType, Types::String.default("n".freeze)
          attribute :dlpsPartlyPublic, Types::String.default("f".freeze)
          attribute :manager, Types::Integer.default(0)
          attribute :lastModifiedTime, Types::Time.default { Time.now }
          attribute :lastModifiedBy, Types::String.default("root".freeze)
          attribute :dlpsDeleted, Types::String.default("f".freeze)


          associations do
            has_many :locations, foreign_key: :coll
            has_many :grants, foreign_key: :coll
          end
        end

        def with_locations
          join(:locations)
        end

        struct_namespace Lauth
        auto_struct true
      end
    end
  end
end
