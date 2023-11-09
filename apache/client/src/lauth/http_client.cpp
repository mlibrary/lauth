#include "lauth/http_client.hpp"

#include <httplib.h>

namespace mlibrary::lauth {
  bool HttpClient::isAllowed(Request req) {
    return req.user == "authorized";
  }

  std::string HttpClient::get(const std::string& path) {
    httplib::Client client(baseUrl);

    auto res = client.Get(path);

    return res->body;
  }
}

