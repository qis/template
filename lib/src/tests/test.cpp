#include <gtest/gtest.h>
#include <lib/test.hpp>

TEST(lib, test)
{
  EXPECT_EQ(lib::test(), "test");
}
