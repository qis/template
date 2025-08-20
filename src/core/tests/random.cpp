#include <gtest/gtest.h>
#include <core/random.hpp>

TEST(core, test) {
  EXPECT_FALSE(core::test().empty());
}

TEST(core, random) {
  EXPECT_FALSE(core::random().empty());
}
