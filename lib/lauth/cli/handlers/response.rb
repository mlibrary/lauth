module Lauth
  module CLI
    module Handlers
      class Response < ::ROM::HTTP::Handlers::JSONResponse
        def self.call(response, dataset)
          case response.code
          when "200"
            json = JSON.parse(response.body)

            # array = []
            # json.each do |record|
            #   array << { id: record["id"], name: record["attributes"]["name"] }
            # end
            # array
            #
            json.map do |record|
              {id: record["id"]}.merge!(record["attributes"])
            end
          else
            warn "#{response.code} : #{response.msg}"
            {}
          end
        end
      end
    end
  end
end
