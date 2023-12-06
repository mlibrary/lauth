module Lauth
  module Determination
    class Denied < Base

      DENIED = "denied"

      def type
        DENIED
      end

    end
  end
end
