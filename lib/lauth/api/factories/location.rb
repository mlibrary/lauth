module Lauth
  module API
    module Factories
      Factory.define(:location, struct_namespace: Lauth::API::ROM::Entities) do |f|
        f.dlpsServer "some.host"
        f.dlpsPath "/s/somecoll%"
        f.coll "somecoll"
        f.lastModifiedTime Time.now
        f.lastModifiedBy "root"
        f.dlpsDeleted "f"
      end
    end
  end
end
