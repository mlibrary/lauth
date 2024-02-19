Factory.define(:group_membership, struct_namespace: Lauth) do |f|
  f.association(:user)
  f.association(:group)
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"

  f.trait(:soft_deleted) do |t|
    t.dlpsDeleted "t"
  end
end
