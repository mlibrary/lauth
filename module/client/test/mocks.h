#ifndef _LAUTH_TEST_MOCKS_H_
#define _LAUTH_TEST_MOCKS_H_

#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "lauth/client.h"
#include "lauth/consts.h"
#include "lauth/http_client.h"
#include "lauth/system.h"

#include <memory>
#include <optional>

using namespace mlibrary::lauth;

class MockSystem : public System {
    public:
    MOCK_METHOD(std::string, getHostname, ());
};

struct StubRawClient : public httplib::Client {
    StubRawClient() : httplib::Client("http://default.invalid") {}
};

class MockHttpClient : public HttpClient {
    public:
    MockHttpClient() : HttpClient(StubRawClient()) {}
    MOCK_METHOD(std::string, getBody, (const std::string&));
};

class MockClient : public v1::Client {
    public:
    MockClient() : v1::Client(std::make_unique<MockHttpClient>()) {}
    MOCK_METHOD(v1::User, getUser, (std::string));
    MOCK_METHOD(AuthenticationMethod, getAuthenticationMethod, (std::string, std::string));
    MOCK_METHOD(std::optional<v1::Collection>, findCollection, (std::string, std::string));
};

#endif
