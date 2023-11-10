#include "lauth/http_client.hpp"

#include <httplib.h>

#include <optional>

namespace mlibrary::lauth {
  std::optional<std::string> HttpClient::getOptional(const std::string& path) {
    httplib::Client client(baseUrl);

    auto res = client.Get(path);
    if (res)
      return res->body;
    else
      return std::nullopt;
  }
}

