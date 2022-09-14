Given("user {string} with id {string} and password {string}") do |name, userid, password|
  Factory[:user, userid: userid, surname: name, userPassword: password]
end

Given("the following users exist:") do |table|
  table.hashes.each do |row|
    Factory[:user, userid: row["id"], surname: row["name"], userPassword: row["password"], dlpsDeleted: row["deleted"]]
  end
end
