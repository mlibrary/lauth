#ifndef _LAUTH_CLIENT_H_
#define _LAUTH_CLIENT_H_

#include "lauth/http_client.h"
#include "lauth/v1/user.h"

#include <memory>
#include <string>

namespace mlibrary::lauth::v1 {

    class Client {
        public:
        Client(std::unique_ptr<HttpClient>&& api) : api(std::move(api)) {};

        virtual User getUser(std::string username);

        std::string url;

        protected:
        std::unique_ptr<HttpClient> api;
    };

};
#endif
