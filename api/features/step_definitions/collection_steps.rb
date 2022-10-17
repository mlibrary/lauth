Given("the following collections exist:") do |table|
  table.hashes.each do |row|
    Factory[:collection, uniqueIdentifier: row["id"], commonName: row["name"], dlpsDeleted: row["deleted"]]
  end
end
