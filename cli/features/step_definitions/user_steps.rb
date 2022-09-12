Given("an authorized user {string} with password {string}") do |user, password|
  Factory[:user, userid: user, userPassword: password]
end
