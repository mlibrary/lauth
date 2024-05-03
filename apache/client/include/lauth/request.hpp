#ifndef __LAUTH_REQUEST_HPP__
#define __LAUTH_REQUEST_HPP__

#include <string>

namespace mlibrary::lauth {
  struct Request {
    std::string ip;
    std::string uri;
    std::string user;
  };
}

#endif // __LAUTH_REQUEST_HPP__

