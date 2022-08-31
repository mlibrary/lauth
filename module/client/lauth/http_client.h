#ifndef _LAUTH_HTTP_CLIENT_H_
#define _LAUTH_HTTP_CLIENT_H_

#define CPPHTTPLIB_OPENSSL_SUPPORT

#include <httplib.h>
#include <string>

namespace mlibrary::lauth {
    class HttpClient {
        public:
        HttpClient(const std::string &host);
        virtual ~HttpClient() = default;

        virtual std::string getBody(const std::string &path);

        protected:
        httplib::Client http;
        HttpClient(httplib::Client &&http) : http(std::move(http)) {};
    };
};

#endif
