#include "lauth/http_client.hpp"

#include <optional>

#ifndef CPPHTTPLIB_OPENSSL_SUPPORT
#define CPPHTTPLIB_OPENSSL_SUPPORT 1
#endif

#include <httplib.h>

#include "lauth/http_params.hpp"
#include "lauth/http_headers.hpp"
#include "lauth/logging.hpp"

namespace mlibrary::lauth {
  std::optional<std::string> HttpClient::get(const std::string& path, const HttpParams& params, const HttpHeaders& headers) {
    httplib::Client client(baseUrl);
    client.set_connection_timeout(5);
    client.set_read_timeout(5);

    // using Headers = std::multimap<std::string, std::string, detail::ci>;
    httplib::Headers marshal_headers ( headers.begin(), headers.end() );

    auto res = client.Get(path, params, marshal_headers);

    if (res && res->status == 200) {
      requestOk(path, res->body.size());
      return res->body;
    } else if (res) {
      requestNotOk(path, res->status);
      return std::nullopt;
    } else {
      requestFailed(path, httplib::to_string(res.error()));
      return std::nullopt;
    }
  }

  std::optional<std::string> HttpClient::get(const std::string& path, const HttpParams& params) {
     return get(path, params, HttpHeaders{});
  }

  std::optional<std::string> HttpClient::get(const std::string& path, const HttpHeaders& headers) {
    return get(path, HttpParams{}, headers);
  }

  std::optional<std::string> HttpClient::get(const std::string& path) {
     return get(path, HttpParams{}, HttpHeaders{});
  }

  void HttpClient::requestOk(const std::string& path, std::size_t size) {
    LAUTH_DEBUG("HTTP request to " << baseUrl << path << " succeeded; response length: " << size);
  }

  void HttpClient::requestNotOk(const std::string& path, int status) {
    LAUTH_DEBUG("HTTP request to " << baseUrl << path << " succeeded but was not 200 OK; status: " << status);
  }

  void HttpClient::requestFailed(const std::string& path, const std::string& error) {
    LAUTH_WARN("HTTP request to " << baseUrl << path << " failed: " << error);
  }
}
