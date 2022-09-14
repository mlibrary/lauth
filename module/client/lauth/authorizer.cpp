#include "lauth/consts.h"
#include "lauth/authorizer.h"

namespace mlibrary::lauth {
    std::map<std::string, AuthenticationMethod> s2AM {
        { "none", AuthenticationMethod::None },
        { "clientAddress", AuthenticationMethod::ClientAddress },
        { "username", AuthenticationMethod::Username },
        { "any", AuthenticationMethod::Any }
    };
    std::map<AuthenticationMethod, std::string> AM2s {
        { AuthenticationMethod::None, "none" },
        { AuthenticationMethod::ClientAddress, "clientAddress" },
        { AuthenticationMethod::Username , "username" },
        { AuthenticationMethod::Any, "any" }
    };

    bool Authorizer::isAuthorized() {
        return false;
    }

    bool Authorizer::isAuthorized(RequestInfo& req) {
        // here we have a new request and config info for the path....
        // we check to see if the path is configured to be authorized at all...
        // we get the hostname from the system...
        // and ask the API: how should this request [server, path] be authorized?
        return false;
    }

    // FIXME: Remove; here only to test injection temporarily
    std::string Authorizer::getHostname() {
        return system->getHostname();
    }

    Result Authorizer::process(RequestInfo& req) {
        auto method = client->getAuthenticationMethod(system->getHostname(), req.uri);
        if (method == AuthenticationMethod::Username) {
            if (req.username.empty()) {
                return Result { .status = STATUS_UNAUTHORIZED };
            }
        }
        return Result { .status = STATUS_ALLOWED };
    }

    /* struct Result { */
    /*     int httpStatus; */
    /*     const vector<std::string>& getPublicCollections() const; */
    /*     const vector<std::string>& getAuthorizedCollections() const; */
    /* }; */
    /* struct Unauthorized : public Result {}; */
    /* struct Allowed : public Result {}; */
    /* struct Forbidden : public Result {}; */
    /* struct Delegated : public Result {}; */
    /* struct Error : public Result {}; */
}
