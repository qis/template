#include <gtest/gtest.h>
#include <company/random.hpp>

TEST(CompanyRandom, ReturnsNonEmptyString) {
  EXPECT_FALSE(company::random().empty());
}

int main(int argc, char** argv) {
  testing::InitGoogleTest(&argc, argv);
  return testing::UnitTest::GetInstance()->Run();
}
