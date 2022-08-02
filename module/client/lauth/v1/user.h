#ifndef _LAUTH_V1_USER_H_
#define _LAUTH_V1_USER_H_

#include <string>

namespace mlibrary::lauth::v1 {

    struct User {
        std::string userid;
        std::string givenName;
        std::string surname;
    };

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


    void to_json(nlohmann::json& j, const User& user);
    void from_json(const nlohmann::json& j, User& user);
};

#endif
