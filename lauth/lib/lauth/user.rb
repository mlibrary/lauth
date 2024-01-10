module Lauth
  class User < ROM::Struct
    def to_s
      userid
    end
  end
end
