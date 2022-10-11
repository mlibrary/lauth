Given("the following institutions exist:") do |table|
  table.hashes.each do |row|
    Factory[:institution, uniqueIdentifier: row["id"].to_i, organizationName: row["name"], dlpsDeleted: row["deleted"]]
  end
end
