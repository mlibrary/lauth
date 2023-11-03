#ifndef __LAUTH_API_CLIENT_HPP__
#define __LAUTH_API_CLIENT_HPP__

#include <memory>

#include "lauth/http_client.hpp"
#include "lauth/request.hpp"

namespace mlibrary::lauth {
  class ApiClient {
    public:
      ApiClient() : client(std::make_unique<HttpClient>()) {};
      ApiClient(std::unique_ptr<HttpClient>&& client) : client(std::move(client)) {};
      ApiClient(const ApiClient&) = delete;
      ApiClient& operator=(const ApiClient&) = delete;
      ApiClient(ApiClient&&) = delete;
      ApiClient& operator=(const ApiClient&&) = delete;
      virtual ~ApiClient() = default;

      virtual bool isAllowed(Request req);

    protected:
      std::unique_ptr<HttpClient> client;
  };
}

#endif // __LAUTH_API_CLIENT_HPP__
