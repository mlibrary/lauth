#ifndef __LAUTH_AUTHORIZER_HPP__
#define __LAUTH_AUTHORIZER_HPP__

#include <memory>
#include <string>

#include "lauth/api_client.hpp"
#include "lauth/request.hpp"

namespace mlibrary::lauth {
  class Authorizer {
    public:
      Authorizer() : client(std::make_unique<ApiClient>()) {};
      Authorizer(std::unique_ptr<ApiClient>&& client) : client(std::move(client)) {};
      Authorizer(const Authorizer&) = delete;
      Authorizer& operator=(const Authorizer&) = delete;
      Authorizer(Authorizer&&) = delete;
      Authorizer& operator=(const Authorizer&&) = delete;
      virtual ~Authorizer() = default;

      virtual bool isAllowed(Request req);

    protected:
      std::unique_ptr<ApiClient> client;
  };
}

#endif // __LAUTH_AUTHORIZER_HPP__
