module Lauth
  module CLI
    module Handlers
      class Response < ::ROM::HTTP::Handlers::JSONResponse
        def self.call(response, dataset)
          # json = JSON.parse(response.body)
          # array = []
          # json.each do |record|
          #   array << { id: record["id"], name: record["attributes"]["name"] }
          # end
          # array

          json = JSON.parse(response.body)
          json.map do |record|
            {id: record["id"]}.merge!(record["attributes"])
          end
        end
      end
    end
  end
end
