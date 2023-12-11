Factory.define(:group, struct_namespace: Lauth) do |f|
  f.sequence(:uniqueIdentifier) { |n| n }
  f.sequence(:commonName) { |n| "Group #{n}" }
  f.manager 0
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"
end
