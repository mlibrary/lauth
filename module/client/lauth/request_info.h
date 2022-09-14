#ifndef _LAUTH_REQUEST_INFO_H_
#define _LAUTH_REQUEST_INFO_H_

#include <string>

namespace mlibrary::lauth {
    struct RequestInfo {
        std::string uri;
        std::string filename;
        std::string username;
    };
};

#endif
