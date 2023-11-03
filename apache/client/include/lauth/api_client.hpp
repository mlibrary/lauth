#ifndef __LAUTH_API_CLIENT_HPP__
#define __LAUTH_API_CLIENT_HPP__

#include "lauth/request.hpp"

namespace mlibrary::lauth {
  class ApiClient {
    public:
      virtual bool isAllowed(Request req);
      virtual ~ApiClient() = default;
  };
}

#endif // __LAUTH_API_CLIENT_HPP__
