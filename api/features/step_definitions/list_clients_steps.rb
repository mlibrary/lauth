Given("there are no clients") do
  # @client = `curl --silent http://127.0.0.1:9292/factories`
  # get "/factories"
end

Given("there is one client {string}") do |name|
  # @client = `curl --silent http://127.0.0.1:9292/factories`
  # @client = `curl --silent http://127.0.0.1:9292/factories/clients`
  # get "/factories"
  # get "/factories/clients"
  # post "/clients?name=#{name}"
  # post "/clients"
  Factory[:client, name: name]
end

Given("there is two clients {string}") do |names|
  # @client = `curl --silent http://127.0.0.1:9292/factories`
  # @clients = []
  # @clients << `curl --silent http://127.0.0.1:9292/factories/clients`
  # @clients << `curl --silent http://127.0.0.1:9292/factories/clients`
  # @clients
  # get "/factories"
  # get "/factories/clients"
  # get "/factories/clients"
  # names.split.each do |name|
  #   post "/clients?name=#{name}"
  # end
  names.split.each do |name|
    Factory[:client, name: name]
  end
end

When("I visit {string}") do |args|
  # @output = `curl --silent http://127.0.0.1:9292/#{args}`.chomp
  # @output
  get "/#{args}"
end

Then("I should see") do |doc_string|
  # expect(@output).to eq(doc_string)
  expect(last_response.body).to eq(doc_string)
end
