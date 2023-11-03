#ifndef _LAUTH_TEST_MOCKS_HPP_
#define _LAUTH_TEST_MOCKS_HPP_

#include <lauth/api_client.hpp>

using namespace mlibrary::lauth;

class MockApiClient : public ApiClient {
    public:
    MOCK_METHOD(bool, isAllowed, (Request), (override));
};

#endif
