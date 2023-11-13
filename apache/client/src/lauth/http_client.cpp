#include "lauth/http_client.hpp"

#include <optional>

#include <httplib.h>

#include "lauth/http_params.hpp"

namespace mlibrary::lauth {
  std::optional<std::string> HttpClient::get(const std::string& path) {
    httplib::Client client(baseUrl);

    auto res = client.Get(path);
    if (res)
      return res->body;
    else
      return std::nullopt;
  }

  std::optional<std::string> HttpClient::get(const std::string& path, const HttpParams& params) {
    httplib::Client client(baseUrl);
    httplib::Headers headers;

    auto res = client.Get(path, params, headers);
    if (res)
      return res->body;
    else
      return std::nullopt;
  }
}
