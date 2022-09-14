module Lauth
  module CLI
    module Handlers
      class Response < ::ROM::HTTP::Handlers::JSONResponse
        def self.call(response, dataset)
          status = response.code.to_i
          if status >= 200 && status < 300
            jsonapi = JSON.parse(response.body)
            data = Array([jsonapi["data"]]).flatten
            array = []
            data.each do |obj|
              array << {"id" => obj["id"]}.merge(obj["attributes"]).transform_keys { |key| key.to_sym }
            end
            case dataset.request_method
            when :post, :put
              array[0]
            else
              array
            end
          else
            response.error!
          end
        end
      end
    end
  end
end
