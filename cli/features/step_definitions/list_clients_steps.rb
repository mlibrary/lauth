Given("there are no clients") do
end

Given("there is one client {string}") do |name|
  Factory[:client, name: name]
end

Given("there is two clients {string}") do |names|
  names.split.each do |name|
    Factory[:client, name: name]
  end
end

When("I enter lauth {string} on the command line") do |args|
  @output = `bin/lauth #{args}`.chomp
end

Then("I should see") do |doc_string|
  expect(@output).to eq(doc_string)
end
