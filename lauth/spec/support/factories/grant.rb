Factory.define(:grant, struct_namespace: Lauth) do |f|
  f.sequence(:uniqueIdentifier) { |n| n }
  f.association(:collection)
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsExpiryTime Time.now
  f.dlpsDeleted "f"

  f.trait(:for_user) do |t|
    t.association(:user)
  end

  f.trait(:for_institution) do |t|
    t.association(:institution)
  end

  f.trait(:for_group) do |t|
    t.association(:group)
  end
end
