Factory.define(:institution_membership, struct_namespace: Lauth) do |f|
  f.association(:user)
  f.association(:institution)
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"
end
