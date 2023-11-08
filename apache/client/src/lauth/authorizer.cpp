#include "lauth/authorizer.hpp"

#include <string>

namespace mlibrary::lauth {
  bool Authorizer::isPasswordOnly(std::string url) {
    return false;
  }

  bool Authorizer::isAllowed(Request req) {
    return client->isAllowed(req);
  }
}