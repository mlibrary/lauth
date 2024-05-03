#ifndef __LAUTH_API_CLIENT_HPP__
#define __LAUTH_API_CLIENT_HPP__

#include <memory>

#include "lauth/http_client.hpp"
#include "lauth/request.hpp"
#include "lauth/authorization_result.hpp"

namespace mlibrary::lauth {
  class ApiClient {
    public:
      ApiClient(const std::string& url, const std::string& bearerToken) : client(std::make_unique<HttpClient>(url)), bearerToken(bearerToken) {};
      ApiClient(std::unique_ptr<HttpClient>&& client) : client(std::move(client)) {};
      ApiClient(std::unique_ptr<HttpClient>&& client, const std::string& bearerToken) : client(std::move(client)), bearerToken(bearerToken) {};
      ApiClient(const ApiClient&) = delete;
      ApiClient& operator=(const ApiClient&) = delete;
      ApiClient(ApiClient&&) = delete;
      ApiClient& operator=(const ApiClient&&) = delete;
      virtual ~ApiClient() = default;

      virtual AuthorizationResult authorize(Request req);

    protected:
      std::unique_ptr<HttpClient> client;
      const std::string bearerToken;
  };
}

#endif // __LAUTH_API_CLIENT_HPP__
