#ifndef __LAUTH_HTTP_CLIENT_HPP__
#define __LAUTH_HTTP_CLIENT_HPP__

#include "lauth/http_params.hpp"
#include "lauth/http_headers.hpp"

#include <optional>
#include <string>

namespace mlibrary::lauth {
  class HttpClient {
    public:
      HttpClient(const std::string& baseUrl) : baseUrl(baseUrl) {};
      virtual ~HttpClient() = default;

      virtual std::optional<std::string> get(const std::string &path);
      virtual std::optional<std::string> get(const std::string &path, const HttpParams &params);
      virtual std::optional<std::string> get(const std::string &path, const HttpHeaders &headers);
      virtual std::optional<std::string> get(const std::string &path, const HttpParams &params, const HttpHeaders &headers);

    protected:
      const std::string baseUrl;
      void requestOk(const std::string& path, std::size_t size);
      void requestNotOk(const std::string& path, int status);
      void requestFailed(const std::string& path, const std::string& error);
  };
}

#endif // __LAUTH_HTTP_CLIENT_HPP__
