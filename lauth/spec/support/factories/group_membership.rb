Factory.define(:group_membership, struct_namespace: Lauth) do |f|
  f.association(:user)
  f.association(:group)
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"
end
