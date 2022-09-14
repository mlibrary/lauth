When("I enter lauth -u {string} -p {string} {string}") do |user, password, args|
  @output = `bin/lauth -u #{user} -p #{password} #{args} 2>&1`.chomp
end

When("I enter lauth {string}") do |args|
  @output = `bin/lauth #{args} 2>&1`.chomp
end

Then("I should see") do |doc_string|
  expect(@output.to_s).to eq(doc_string.to_s)
end

Then("I should see {string}") do |output|
  expect(@output).to eq(output)
end

Then('I should see "error: {int} {string}"') do |code, message|
  expect(@output).to eq("error: #{code} \"#{message}\"")
end
