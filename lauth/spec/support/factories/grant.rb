Factory.define(:grant, struct_namespace: Lauth::Persistence::Entities) do |f|
  f.sequence(:uniqueIdentifier) { |n| n }
  f.association(:user)
  f.association(:collection)
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsExpiryTime Time.now
  f.dlpsDeleted "f"
end
