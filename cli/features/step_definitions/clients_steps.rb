Given("the following clients exist:") do |table|
  table.hashes.each do |row|
    Factory[:client, id: row["id"], name: row["name"]]
  end
end
