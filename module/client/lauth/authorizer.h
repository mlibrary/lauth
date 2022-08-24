#ifndef _LAUTH_AUTHORIZER_H_
#define _LAUTH_AUTHORIZER_H_

#include "lauth/request_info.h"

#include <string>

namespace mlibrary::lauth {
    class System {
        public:
        virtual std::string getHostname();
        virtual ~System() = default;
    };

    class Authorizer {
        public:
        Authorizer();
        Authorizer(System *system);
        ~Authorizer();
        bool isAuthorized();
        bool isAuthorized(RequestInfo& req);

        std::string getHostname();
        protected:
        System *system;
        bool defaultCleanup = false;

        private:
        Authorizer(const Authorizer&) = delete;
        Authorizer& operator=(const Authorizer&) = delete;
        Authorizer(Authorizer&&) = delete;
        Authorizer& operator=(Authorizer&&) = delete;
    };
}

#endif
