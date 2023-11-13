#ifndef _LAUTH_TEST_MOCKS_HPP_
#define _LAUTH_TEST_MOCKS_HPP_

#include "lauth/api_client.hpp"
#include "lauth/http_client.hpp"

#include <optional>

using namespace mlibrary::lauth;

class MockHttpClient : public HttpClient {
    public:
    MockHttpClient() : HttpClient("http://api.invalid") {};
    MOCK_METHOD(std::optional<std::string>, get, (const std::string&), (override));
};

class MockApiClient : public ApiClient {
    public:
    MockApiClient() : ApiClient(std::make_unique<MockHttpClient>()) {};
    MOCK_METHOD(bool, isAllowed, (Request), (override));
};

#endif
