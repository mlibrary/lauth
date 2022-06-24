module Lauth
  class App < Hanami::API
    get "/" do
      "This is the Lauth, and our version is #{Lauth::VERSION}."
    end

    get "/clients" do
      client_repo = Repositories::Client.new(Lauth.container)

      top_level = {
        data: []
      }

      top_level[:data] << client_repo.create(id: 1, name: "one").resource_object
      top_level[:data] << client_repo.create(id: 2, name: "two").resource_object
      top_level[:data] << client_repo.create(id: 3, name: "three").resource_object
      top_level[:data] << client_repo.create(id: 4, name: "four").resource_object

      top_level.to_json
    end
  end
end
