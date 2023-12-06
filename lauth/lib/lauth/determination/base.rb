module Lauth
  module Determination
    class Base

      def type
        raise NotImplementedError
      end

      def eql?(other)
        type == other.to_s
      end
      alias == eql?

      def to_s
        to_str
      end

      def to_str
        type
      end

      def inspect
        to_s
      end

    end
  end
end
