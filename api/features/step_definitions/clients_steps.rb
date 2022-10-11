Given("the following clients exist:") do |table|
  table.hashes.each do |row|
    Factory[:client, id: row["id"].to_i, name: row["name"]]
  end
end
