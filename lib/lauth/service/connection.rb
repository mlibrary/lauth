require "faraday"
require "faraday_middleware"
require "json"

module Lauth
  module Service
    class Connection
      def get(*args)
        faraday.get(*args)
      end

      def initialize(options = {})
        @base = options[:base]
        @token = options[:token]
      end

      def faraday
        @faraday ||= Faraday.new(@base) do |conn|
          conn.headers = {
            authorization: "Bearer #{@token}",
            accept: "application/json, application/vnd.heliotrope.v1+json",
            content_type: "application/json"
          }
          conn.request :json
          conn.response :json, content_type: /\bjson$/
          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end
