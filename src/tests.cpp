#include <core/random.hpp>
#include <gtest/gtest.h>

TEST(Core, Random) {
  EXPECT_FALSE(core::random().empty());
}

int main(int argc, char** argv) {
  testing::InitGoogleTest(&argc, argv);
  return testing::UnitTest::GetInstance()->Run();
}
