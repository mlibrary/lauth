Factory.define(:location, struct_namespace: Lauth) do |f|
  f.dlpsServer "some.host"
  f.dlpsPath "/s/somecoll%"
  f.association(:collection)
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"

  f.trait(:restricted_by_username) do |t|
    t.dlpsPath "/restricted-by-username%"
  end

  f.trait(:restricted_by_client_ip) do |t|
    t.dlpsPath "/restricted-by-client-ip%"
  end

  f.trait(:restricted_by_username_or_client_ip) do |t|
    t.dlpsPath "/restricted-by-username-or-client-ip%"
  end
end
