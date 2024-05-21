#ifndef __LAUTH_AUTHORIZER_HPP__
#define __LAUTH_AUTHORIZER_HPP__

#include <map>
#include <memory>
#include <string>

#include "lauth/api_client.hpp"
#include "lauth/request.hpp"

namespace mlibrary::lauth {
  class Authorizer {
    public:
      Authorizer(const std::string& url, const std::string& bearerToken) : client(std::make_unique<ApiClient>(url, bearerToken)) {};
      Authorizer(std::unique_ptr<ApiClient>&& client) : client(std::move(client)) {};
      Authorizer(const Authorizer&) = delete;
      Authorizer& operator=(const Authorizer&) = delete;
      Authorizer(Authorizer&&) = delete;
      Authorizer& operator=(const Authorizer&&) = delete;
      virtual ~Authorizer() = default;

      virtual std::map<std::string, std::string> authorize(Request req);

    protected:
      std::unique_ptr<ApiClient> client;
  };
}

#endif // __LAUTH_AUTHORIZER_HPP__
