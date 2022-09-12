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
