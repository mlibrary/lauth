Given("the following groups exist:") do |table|
  table.hashes.each do |row|
    Factory[:group, uniqueIdentifier: row["id"].to_i, commonName: row["name"], dlpsDeleted: row["deleted"]]
  end
end
