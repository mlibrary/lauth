require "base64"

Given("no user credentials") do
end

Given("user credentials {string}") do |basic|
  header "X-Auth", Base64.encode64(basic).to_s
end

Given("user {string} with credentials {string}") do |name, credentials|
  userid, password = credentials.split(":")
  Factory[:user, userid: userid, surname: name, userPassword: password]
  header "X-Auth", Base64.encode64(credentials).to_s
end

Given("the following users exist:") do |table|
  table.hashes.each do |row|
    Factory[:user, userid: row["id"], surname: row["name"], dlpsDeleted: row["deleted"]]
  end
end
