#ifndef _LAUTH_CLIENT_H_
#define _LAUTH_CLIENT_H_

#include "lauth/http_client.h"
#include "lauth/v1/user.h"

#include <string>

namespace mlibrary::lauth::v1 {

    class Client {
        public:
        Client(HttpClient *api);

        User getUser(std::string username);

        std::string url;

        protected:
        HttpClient *api;
    };

};
#endif
