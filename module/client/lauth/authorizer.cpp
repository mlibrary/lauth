#include "lauth/authorizer.h"

#include <memory>
#include <string>
#include <unistd.h>

namespace mlibrary::lauth {
    std::string System::getHostname() {
        char servername[129];
        gethostname(servername, 128);
        servername[128] = '\0';
        return std::string(servername);
    }

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
