#ifndef _LAUTH_AUTHORIZER_H_
#define _LAUTH_AUTHORIZER_H_

#include "lauth/client.h"
#include "lauth/request_info.h"
#include "lauth/system.h"

#include <memory>
#include <string>

namespace mlibrary::lauth {
    class Authorizer {
        public:
        Authorizer() : system(std::make_unique<System>()) {};
        Authorizer(std::unique_ptr<System>&& system) : system(std::move(system)) {};
        Authorizer(
            std::unique_ptr<System>&& system,
            std::unique_ptr<v1::Client>&& api
        ) : system(std::move(system)), client(std::move(api)) {};
        Authorizer(const Authorizer&) = delete;
        Authorizer& operator=(const Authorizer&) = delete;
        Authorizer(Authorizer&&) = delete;
        Authorizer& operator=(Authorizer&&) = delete;

        bool isAuthorized();
        bool isAuthorized(RequestInfo& req);

        std::string getHostname();
        protected:
        std::unique_ptr<System> system;
        std::unique_ptr<v1::Client> client;
        bool defaultCleanup = false;
    };
}

#endif
