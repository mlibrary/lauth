#ifndef __LAUTH_AUTHORIZER_HPP__
#define __LAUTH_AUTHORIZER_HPP__

#include <string>

#include "lauth/request.hpp"

namespace mlibrary::lauth {
  class Authorizer {
    public:
      bool isPasswordOnly(std::string url);
      bool isAllowed(Request req);
  };
}

#endif // __LAUTH_AUTHORIZER_HPP__
