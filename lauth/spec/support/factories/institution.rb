Factory.define(:institution, struct_namespace: Lauth) do |f|
  f.sequence(:uniqueIdentifier) { |n| n }
  f.sequence(:organizationName) { |n| "Institution #{n}" }
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"

  f.trait(:soft_deleted) do |t|
    t.dlpsDeleted "t"
  end
end
