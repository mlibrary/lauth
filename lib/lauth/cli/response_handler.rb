module Lauth
  module Cli
    class ResponseHandler
      def call(response, dataset)
        if %(post put patch).include?(dataset.request_method)
          JSON.parse(response.body, symbolize_names: true)
        else
          Array([JSON.parse(response.body, symbolize_names: true)]).flatten
        end
      end
    end
  end
end
