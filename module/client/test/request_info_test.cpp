#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "lauth/request_info.h"

using namespace mlibrary::lauth;

TEST(RequestInfoTest, HasUri) {
    RequestInfo req;
    req.uri = "/a/url";
    EXPECT_THAT(req.uri, "/a/url");
}

TEST(RequestInfoTest, HasFilename) {
    RequestInfo req;
    req.filename = "/path/on/disk";
    EXPECT_THAT(req.filename, "/path/on/disk");
}
