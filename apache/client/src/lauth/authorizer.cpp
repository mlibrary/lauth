#include "lauth/authorizer.hpp"

#include <string>

namespace mlibrary::lauth {
  int Authorizer::foo() {
    return 12;
  }

  std::string Authorizer::bar(RequestInfo req) {
    return req.foo;
  }
}
