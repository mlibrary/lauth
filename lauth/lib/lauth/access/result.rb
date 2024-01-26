module Lauth
  module Access
    class Result
      attr_reader :determination, :authorized_collections, :public_collections

      def initialize(determination: "denied", authorized_collections: [], public_collections: [])
        @determination = determination
        @authorized_collections = authorized_collections
        @public_collections = public_collections
      end

      def to_h
        {
          determination: determination,
          authorized_collections: authorized_collections,
          public_collections: public_collections
        }
      end

      def ==(other)
        to_h == other.to_h
      end
      alias_method :eql?, :==

      def to_s
        "#{self.class}<#{to_h}>"
      end
      alias_method :inspect, :to_s
    end
  end
end
