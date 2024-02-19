Factory.define(:group, struct_namespace: Lauth) do |f|
  f.sequence(:uniqueIdentifier) { |n| n }
  f.sequence(:commonName) { |n| "Group #{n}" }
  f.manager 0
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"

  f.trait(:soft_deleted) do |t|
    t.dlpsDeleted "t"
  end
end
