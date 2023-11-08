#include "lauth/http_client.hpp"

namespace mlibrary::lauth {

  bool HttpClient::isAllowed(Request req) {
    return (req.user == "authorized");
  }

  std::string HttpClient::get(const std::string& url) {
    return "Root";
  }
}

