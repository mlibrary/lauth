Given("an unknown user {string} with password {string}") do |user, password|
end

Given("a known user {string} with password {string}") do |user, password|
  Factory[:user, userid: user, userPassword: password]
end
