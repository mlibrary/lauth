When("I enter lauth -u {string} -p {string} {string}") do |user, password, args|
  @output = `bin/lauth -u #{user} -p #{password} #{args}`.chomp
end

When("I enter lauth {string}") do |args|
  @output = `bin/lauth #{args}`.chomp
end

Then("I should see") do |doc_string|
  expect(@output).to eq(doc_string)
end
