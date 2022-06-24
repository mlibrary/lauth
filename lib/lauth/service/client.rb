module Lauth
  module Service
    class Client
      def list
        rv = []

        response = @connection.get("clients")
        return rv unless response.success?

        parsed = JSON.parse(response.body, symbolize_names: true)
        parsed[:data].each do |e|
          rv << e[:id]
        end
        rv
      end

      def initialize(connection)
        @connection = connection
      end
    end
  end
end
