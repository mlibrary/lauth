#ifndef _LAUTH_CLIENT_H_
#define _LAUTH_CLIENT_H_

#include <string>

#define CPPHTTPLIB_OPENSSL_SUPPORT
#include <httplib.h>
#include <json.hpp>

namespace mlibrary::lauth::v1 {

    struct User {
        std::string userid;
        std::string givenName;
        std::string surname;
    };

    void to_json(nlohmann::json& j, const User& user);
    void from_json(const nlohmann::json& j, User& user);


/* countryName */
/* description */
/* dlpsCourse */
/* dlpsDeleted */
/* dlpsExpiryTime */
/* string dlpsKey */
/* string givenName */
/* string initials\": null, */
/* lastModifiedBy\": \"root\", */
/* lastModifiedTime\": \"2022-07-06 13:14:33 +0000\", */
/* localityName\": null, */
/* manager\": 0, */
/* organizationalStatus\": null, */
/* organizationalUnitName\": null, */
/* personalTitle\": null, */
/* postalAddress\": null, */
/* postalCode\": null, */
/* rfc822Mailbox\": \"lit-cs-sysadmin@umich.edu\", */
/* stateOrProvinceName\": null, */
/* string surname\": \"User\", */
/* telephoneNumber\": null, */
/* userPassword\": \"!none\", */
/* string userid\": \"root\" */

    class Client {
        public:
        Client(std::string url);

        User getUser(std::string username);

        std::string url;
    };

};
#endif
