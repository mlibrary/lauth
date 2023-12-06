module Lauth
  module Determination
    class Denied < Base

      DENIED = "denied"

      def self.type
        DENIED
      end

    end
  end
end
