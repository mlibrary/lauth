#ifndef _LAUTH_AUTHORIZER_H_
#define _LAUTH_AUTHORIZER_H_

#include "lauth/request_info.h"

#include <memory>
#include <string>

namespace mlibrary::lauth {
    class System {
        public:
        virtual std::string getHostname();
        virtual ~System() = default;
    };

    class Authorizer {
        public:
        Authorizer() : system(std::make_unique<System>()) {};
        Authorizer(std::unique_ptr<System>&& system) : system(std::move(system)) {};
        Authorizer(const Authorizer&) = delete;
        Authorizer& operator=(const Authorizer&) = delete;
        Authorizer(Authorizer&&) = delete;
        Authorizer& operator=(Authorizer&&) = delete;

        bool isAuthorized();
        bool isAuthorized(RequestInfo& req);

        std::string getHostname();
        protected:
        std::unique_ptr<System> system;
        bool defaultCleanup = false;
    };
}

#endif
