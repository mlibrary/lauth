#ifndef _LAUTH_TEST_MOCKS_HPP_
#define _LAUTH_TEST_MOCKS_HPP_

#include "lauth/api_client.hpp"
#include "lauth/http_client.hpp"

using namespace mlibrary::lauth;

class MockApiClient : public ApiClient {
    public:
    MOCK_METHOD(bool, isAllowed, (Request), (override));
};

class MockHttpClient : public HttpClient {
    public:
    MockHttpClient() : HttpClient("http://localhost:9000") {};
    MOCK_METHOD(bool, isAllowed, (Request), (override));
};

#endif
