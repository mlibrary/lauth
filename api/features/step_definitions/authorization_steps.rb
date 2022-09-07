require "base64"

Given("no user credentials") do
end

Given("user credentials {string}") do |basic|
  header "X-Auth", Base64.encode64(basic).to_s
end

Given("an authorized user with credentials {string}") do |credentials|
  user, password = credentials.split(":")
  Factory[:user, userid: user, surname: user, userPassword: password]
  header "X-Auth", Base64.encode64(credentials).to_s
end
