#include "lauth/authorizer.hpp"

#include <string>

namespace mlibrary::lauth {
  bool Authorizer::isPasswordOnly(std::string url) {
    return false;
  }

  bool Authorizer::isAllowed(Request req) {
    // return (req.user == "lauth-allowed");
    return client->isAllowed(req);
  }
}
