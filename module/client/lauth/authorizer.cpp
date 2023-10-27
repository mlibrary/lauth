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

    AuthenticationMethod Authorizer::getAuthenticationMethod(const v1::Collection& coll) const {
        auto method = coll.authenticationMethod;
        if (method == "clientAddress") {
            return AuthenticationMethod::ClientAddress;
        } else if (method == "username") {
            return AuthenticationMethod::Username;
        } else if (method == "any") {
            return AuthenticationMethod::Any;
        } else {
            return AuthenticationMethod::None;
        }
    }

    Result Authorizer::checkUsername(const v1::Collection& coll, const std::string& username) const {
        if (username.empty())
            return Result { .status = STATUS_UNAUTHORIZED };

        if (username == "lauth-allowed")
            return Result { .status = STATUS_ALLOWED };
        else
            return Result { .status = STATUS_FORBIDDEN };
    }

    Result Authorizer::process(RequestInfo& req) {
        auto coll = client->findCollection(system->getHostname(), req.uri);
        if (!coll)
            return Result { .status = STATUS_ALLOWED };

        auto method = getAuthenticationMethod(*coll);
        if (method == AuthenticationMethod::Username) {
            return checkUsername(*coll, req.username);
        }

        return Result { .status = STATUS_FORBIDDEN };
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
