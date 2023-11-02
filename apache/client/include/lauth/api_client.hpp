#ifndef __LAUTH_API_CLIENT_HPP__
#define __LAUTH_API_CLIENT_HPP__

#include "lauth/request.hpp"

namespace mlibrary::lauth {
  class ApiClient {
    public:
      bool isAllowed(Request req);
  };
}

#endif // __LAUTH_API_CLIENT_HPP__
