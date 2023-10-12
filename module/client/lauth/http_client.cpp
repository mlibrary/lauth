#include "lauth/http_client.h"

#include <httplib.h>
#include <string>

namespace mlibrary::lauth {
    HttpClient::HttpClient(const std::string &host) : http(host)
    {
    }

    std::string HttpClient::getBody(const std::string &path) {
        auto response = http.Get(path.c_str());
        return response->body;
    }
};

