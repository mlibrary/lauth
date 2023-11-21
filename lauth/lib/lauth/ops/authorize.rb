module Lauth
  module Ops
    class Authorize
      def initialize(request:)
        @request = request
      end

      def self.call(request:)
        new(request: request).call
      end

      def call
        Lauth::Access::Result.new(determination: "denied")
      end
    end
  end
end
