#include "lauth/authorizer.h"

#include <string>
#include <unistd.h>

#include <iostream>
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

    Authorizer::Authorizer() {
        defaultCleanup = true;
        system = new System;
    }

    Authorizer::Authorizer(System *system)
        : system(system)
    {
        if (system == nullptr) {
            throw std::invalid_argument("system must not be null");
        }
    }

    Authorizer::~Authorizer() {
        if (defaultCleanup) {
            delete system;
            system = nullptr;
        }
    }

    // FIXME: Remove; here only to test injection temporarily
    std::string Authorizer::getHostname() {
        return system->getHostname();
    }
}
