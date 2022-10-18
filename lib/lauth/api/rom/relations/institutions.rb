module Lauth
  module API
    module ROM
      module Relations
        class Institutions < ::ROM::Relation[:sql]
          schema(:aa_inst, infer: true, as: :institutions) do
            # attribute :uniqueIdentifier, Types::Integer.default { AutoIncrement.id }
            # attribute :organizationName, Types::String
            attribute :manager, Types::Integer.default(0)
            # attribute :lastModifiedTime, Types::Time.default { Time.now }
            attribute :lastModifiedBy, Types::String.default("root".freeze)
            attribute :dlpsDeleted, Types::String.default("f".freeze)
          end

          struct_namespace Entities
          auto_struct true
        end
      end
    end
  end
end
