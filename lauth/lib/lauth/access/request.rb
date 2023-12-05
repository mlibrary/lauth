module Lauth
  module Access
    Request = Struct.new(:uri, :user, :client_ip)
  end
end
