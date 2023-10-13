When("I post {string} to {string}") do |json, url|
  post "/#{url}", json, "CONTENT_TYPE" => "application/json"
end

When("I visit {string}") do |url|
  get "/#{url}"
end

When("I put {string} to {string}") do |json, url|
  put "/#{url}", json, "CONTENT_TYPE" => "application/json"
end

When("I delete {string}") do |url|
  delete "/#{url}"
end

Then("I should see") do |doc_string|
  expected = doc_string
  expected = JSON.parse(doc_string) unless doc_string.empty?
  expect(JSON.parse(last_response.body)).to eq(expected)
end
