#ifndef _LAUTH_CLIENT_H_
#define _LAUTH_CLIENT_H_

#include "lauth/consts.h"
#include "lauth/http_client.h"
#include "lauth/v1/collection.h"
#include "lauth/v1/user.h"

#include <memory>
#include <optional>
#include <string>

using mlibrary::lauth::AuthenticationMethod;

namespace mlibrary::lauth::v1 {
    class Client {
        public:
        Client(std::unique_ptr<HttpClient>&& api) : api(std::move(api)) {};
        virtual ~Client() = default;

        virtual User getUser(std::string username);
        virtual AuthenticationMethod getAuthenticationMethod(std::string server, std::string uri);
        virtual std::optional<Collection> findCollection(std::string server, std::string uri);

        std::string url;

        protected:
        std::unique_ptr<HttpClient> api;
    };

};
#endif
