#include "lauth/http_client.hpp"

#include <httplib.h>

namespace mlibrary::lauth {
  std::string HttpClient::get(const std::string& path) {
    httplib::Client client(baseUrl);

    auto res = client.Get(path);

    return res->body;
  }
}

