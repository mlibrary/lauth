module Lauth
  module Access
    Result = Struct.new(
      :determination,
      :authorized_collections,
      :public_collections
    )
  end
end
