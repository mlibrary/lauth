Factory.define(:collection, struct_namespace: Lauth) do |f|
  f.sequence(:uniqueIdentifier) { |n| "Identifier#{n}" }
  f.sequence(:commonName) { |n| "Name#{n}" }
  f.association(:locations, count: 0)
  f.manager 0
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"

  f.trait(:restricted_to_users) do |t|
    t.association(:locations, :restricted_to_users, count: 1)
  end
end
