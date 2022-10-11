module Lauth
  module API
    module Repositories
      module AA
        class Institution < ::ROM::Repository[:institutions]
          commands :create, update: :by_pk, delete: :by_pk

          struct_namespace Lauth::API::ROM::Entities
          auto_struct true

          protected

          def all_institutions
            institutions.rename(uniqueIdentifier: :id, organizationName: :name)
          end

          def undeleted_institutions
            institutions.where(dlpsDeleted: "f").rename(uniqueIdentifier: :id, organizationName: :name)
          end

          def deleted_institutions
            institutions.where(dlpsDeleted: "t").rename(uniqueIdentifier: :id, organizationName: :name)
          end

          private

          def institutions
            super
          end
        end
      end
    end
  end
end
