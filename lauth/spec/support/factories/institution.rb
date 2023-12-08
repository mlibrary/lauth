Factory.define(:institution, struct_namespace: Lauth) do |f|
  f.sequence(:uniqueIdentifier) { |n| n }
  f.sequence(:organizationName) { |n| "Institution #{n}" }
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"
end
