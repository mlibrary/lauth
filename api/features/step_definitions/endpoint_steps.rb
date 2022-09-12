When("I visit {string}") do |args|
  get "/#{args}"
end

Then("I should see") do |doc_string|
  expect(last_response.body).to eq(doc_string)
end
