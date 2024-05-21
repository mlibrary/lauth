#include "lauth/http_client.hpp"

#include <optional>

#include <httplib.h>

#include "lauth/http_params.hpp"
#include "lauth/http_headers.hpp"

namespace mlibrary::lauth {
  std::optional<std::string> HttpClient::get(const std::string& path, const HttpParams& params, const HttpHeaders& headers) {
    httplib::Client client(baseUrl);

    // using Headers = std::multimap<std::string, std::string, detail::ci>;
    httplib::Headers marshal_headers ( headers.begin(), headers.end() );

    auto res = client.Get(path, params, marshal_headers);
    if (res)
      return res->body;
    else
      return std::nullopt;
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
}
