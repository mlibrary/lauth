# Factory.define(:clients, struct_namespace: Lauth::Relations) do |f|
module Lauth
  module API
    module ROM
      module Relations
        Factory.define(:user, struct_namespace: Lauth::API::ROM::Entities) do |f|
          f.sequence(:userid) { |n| "user#{n}" }
          f.sequence(:givenName) { |n| "name#{n}" }
          f.sequence(:surname) { |n| "surname#{n}" }
          f.sequence(:dlpsKey) { |n| "dlpsKey#{n}" }
          f.sequence(:userPassword) { |n| "password#{n}" }
          f.lastModifiedTime Time.now
          f.lastModifiedBy "root"
          f.dlpsDeleted "f"
        end
      end
    end
  end
end
