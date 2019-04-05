#include <core/test.hpp>
#include <gtest/gtest.h>

TEST(core, core)
{
  EXPECT_EQ(core::test(), "test");
}
