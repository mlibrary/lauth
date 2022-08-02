#ifndef _LAUTH_CLIENT_H_
#define _LAUTH_CLIENT_H_

#define CPPHTTPLIB_OPENSSL_SUPPORT
#include <httplib.h>
#include <json.hpp>

#include "lauth/v1/user.h"

#include <string>

namespace mlibrary::lauth::v1 {

    class Client {
        public:
        Client(std::string url);

        User getUser(std::string username);

        std::string url;
    };

};
#endif
