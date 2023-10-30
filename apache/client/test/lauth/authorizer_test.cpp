#include "lauth/authorizer.hpp"
#include "lauth/request_info.hpp"

#include <gtest/gtest.h>

using mlibrary::lauth::Authorizer;

TEST(Authorizer, foo_is_12) {
  Authorizer authorizer;
  EXPECT_EQ(12, authorizer.foo());
}

TEST(Authorizer, echoes_input) {
  Authorizer authorizer;
  mlibrary::lauth::RequestInfo req {
    .foo = "baz"
  };
  EXPECT_EQ("baz", authorizer.bar(req));
}
