#include "lauth/http_client.hpp"

namespace mlibrary::lauth {
  HttpClient::HttpClient(std::string host, uint16_t port) {

  }

  bool HttpClient::isAllowed(Request req) {
    return (req.user == "authorized");
  }
}

