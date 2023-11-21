module Lauth
  module Persistence
    module Relations
      class Users < ROM::Relation[:sql]
        schema(:aa_user, infer: true, as: :users) do
          # attribute :userid, Types::String.default { AutoIncrement.id }
          # attribute :personalTitle, Types::String.default("".freeze)
          # attribute :givenName, Types::String.default("".freeze)
          # attribute :initials, Types::String.default("".freeze)
          # attribute :surname, Types::String.default("".freeze)
          # attribute :rfc822Mailbox, Types::String.default("".freeze)
          # attribute :organizationalUnitName, Types::String.default("".freeze)
          # attribute :postalAddress, Types::String.default("".freeze)
          # attribute :localityName, Types::String.default("".freeze)
          # attribute :stateOrProvinceName, Types::String.default("".freeze)
          # attribute :postalCode, Types::String.default("".freeze)
          # attribute :countryName, Types::String.default("".freeze)
          # attribute :telephoneNumber, Types::String.default("".freeze)
          # attribute :organizationalStatus, Types::String.default("".freeze)
          # attribute :dlpsCourse, Types::String.default("".freeze)
          attribute :dlpsKey, Types::String.default("".freeze)
          attribute :userPassword, Types::String.default("!".freeze)
          attribute :manager, Types::Integer.default(0)
          # attribute :description, Types::String.default("".freeze)
          # attribute :lastModifiedTime, Types::Time.default { Time.now }
          attribute :lastModifiedBy, Types::String.default("root".freeze)
          # attribute :dlpsExpiryTime, Types::DateTime.default { DateTime.now }
          attribute :dlpsDeleted, Types::String.default("f".freeze)

          associations do
            has_many :aa_may_access, as: :grants, relation: :grants, foreign_key: :userid
          end
        end

        struct_namespace Entities
        auto_struct true
      end
    end
  end
end
