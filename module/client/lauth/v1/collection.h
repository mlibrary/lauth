#ifndef _LAUTH_V1_COLLECTION_H_
#define _LAUTH_V1_COLLECTION_H_

#include <json.hpp>

#include <string>
#include <list>

using json = nlohmann::json;

namespace mlibrary::lauth::v1 {
    struct Collection {
        std::string id;
        std::string authenticationMethod;
    };

    void to_json(nlohmann::json& j, const Collection& collection);
    void from_json(const nlohmann::json& j, Collection& collection);
};

#endif
