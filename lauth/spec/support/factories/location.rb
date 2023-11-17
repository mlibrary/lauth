Factory.define(:location, struct_namespace: Lauth::Persistence::Entities) do |f|
  f.dlpsServer "some.host"
  f.dlpsPath "/s/somecoll%"
  f.association(:collection)
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"

  f.trait(:restricted_to_users) do |t|
    t.dlpsPath "/user%"
  end
end
