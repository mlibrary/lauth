#ifndef __LAUTH_AUTHORIZER_HPP__
#define __LAUTH_AUTHORIZER_HPP__

#include <string>

#include "lauth/request_info.hpp"

namespace mlibrary::lauth {
  class Authorizer {
    public:
      int foo();
      std::string bar(RequestInfo req);
  };
}

#endif // __LAUTH_AUTHORIZER_HPP__
