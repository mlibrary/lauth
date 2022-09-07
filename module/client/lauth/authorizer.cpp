#include "lauth/authorizer.h"

namespace mlibrary::lauth {
    bool Authorizer::isAuthorized() {
        return false;
    }

    bool Authorizer::isAuthorized(RequestInfo& req) {
        return false;
    }

    // FIXME: Remove; here only to test injection temporarily
    std::string Authorizer::getHostname() {
        return system->getHostname();
    }
}
