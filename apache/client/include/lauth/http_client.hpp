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
  };
}

#endif // __LAUTH_HTTP_CLIENT_HPP__
