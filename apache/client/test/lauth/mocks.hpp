#ifndef _LAUTH_TEST_MOCKS_HPP_
#define _LAUTH_TEST_MOCKS_HPP_

#include "lauth/api_client.hpp"
#include "lauth/authorization_result.hpp"
#include "lauth/http_client.hpp"
#include "lauth/http_params.hpp"
#include "lauth/http_headers.hpp"

#include <optional>

using namespace mlibrary::lauth;

class MockHttpClient : public HttpClient {
    public:
    MockHttpClient() : HttpClient("http://api.invalid") {};
    MOCK_METHOD(std::optional<std::string>, get, (const std::string&), (override));
    MOCK_METHOD(std::optional<std::string>, get, (const std::string&, const HttpParams&), (override));
    MOCK_METHOD(std::optional<std::string>, get, (const std::string&, const HttpHeaders&), (override));
    MOCK_METHOD(std::optional<std::string>, get, (const std::string&, const HttpParams&, const HttpHeaders&), (override));
};

class MockApiClient : public ApiClient {
    public:
    MockApiClient() : ApiClient(std::make_unique<MockHttpClient>()) {};
    MOCK_METHOD(AuthorizationResult, authorize, (Request), (override));
};

#endif
