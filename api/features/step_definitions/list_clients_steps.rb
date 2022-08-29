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

When("I visit {string}") do |args|
  get "/#{args}"
end

Then("I should see") do |doc_string|
  expect(last_response.body).to eq(doc_string)
end
