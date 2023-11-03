Factory.define(:collection, struct_namespace: Lauth) do |f|
  f.sequence(:uniqueIdentifier) { |n| "Identifier#{n}" }
  f.sequence(:commonName) { |n| "Name#{n}" }
  f.association(:locations, count: 0)
  f.manager 0
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"

  f.trait(:restricted_by_username) do |t|
    t.uniqueIdentifier "lauth-by-username"
    t.association(:locations, :restricted_by_username, count: 1)
  end

  f.trait(:restricted_by_client_ip) do |t|
    t.uniqueIdentifier "lauth-by-client-ip"
    t.association(:locations, :restricted_by_client_ip, count: 1)
  end
end
