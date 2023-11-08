#ifndef __LAUTH_HTTP_CLIENT_HPP__
#define __LAUTH_HTTP_CLIENT_HPP__

#include "lauth/request.hpp"

namespace mlibrary::lauth {
  class HttpClient {
    public:
      HttpClient(std::string host = "", uint16_t port = 0);
      virtual ~HttpClient() = default;
      
      virtual bool isAllowed(Request req);
  };
}

#endif // __LAUTH_HTTP_CLIENT_HPP__
