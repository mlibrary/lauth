Given("the following networks exist:") do |table|
  table.hashes.each do |row|
    Factory[:network, uniqueIdentifier: row["id"].to_i, dlpsCIDRAddress: row["cidr"], dlpsDeleted: row["deleted"]]
  end
end
