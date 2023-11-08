#ifndef __LAUTH_HTTP_CLIENT_HPP__
#define __LAUTH_HTTP_CLIENT_HPP__

#include "lauth/request.hpp"

namespace mlibrary::lauth {
  class HttpClient {
    public:
      HttpClient(const std::string& baseUrl) : baseUrl(baseUrl) {};
      virtual ~HttpClient() = default;

      virtual bool isAllowed(Request req);

    protected:
      const std::string baseUrl;
  };
}

#endif // __LAUTH_HTTP_CLIENT_HPP__
