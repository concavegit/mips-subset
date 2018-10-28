/*
 * Testbench
 * This rigorously tests the alu unit.
 * Because of some quirks with passing a pointer to functions in
 * succession, many of the functions pass const values representing
 * the alu object's values, rather than simply taking only the alu as
 * an argument.
 */

#include <verilated.h>
#include <limits>
#include <random>
#include <tuple>
#include <iostream>

#include <Valu.h>

/**
 * Warn if the result and zero flag are mismatched.
 * This is used in the other checkers.
 *
 * @param dut the device under testing.
 * @param a the dut's operandA.
 * @param b the dut's operandB.
 * @param command the dut's command.
 * @param desc the symbol representing the command.
 */
void checkZero(Valu* dut, const int a, const int b, const int command, std::string desc)
{
  dut->operandA = a;
  dut->operandB = b;
  dut->command = command;
  dut->eval();
  if (((int) dut->result == 0) != dut->zero)
    printf("zero is %d for %d %s %d, should be %d, %d, %d, %d\n",
           dut->zero, dut->operandA, desc.c_str(), dut->operandB,
           (int) dut->result == 0, dut->command, dut->result, dut->zero);
}

/**
 * Warn if the overflow or carry bits are nonzero.
 * This is used in the non-addition or subtraction checkers.
 *
 * @param dut the device under testing
 * @param a the dut's operandA.
 * @param b the dut's operandB.
 * @param command the dut's command.
 * @param desc the symbol representing the command.
 */
void flagsZero(Valu* dut, const int a, const int b, const int command, std::string desc)
{
  dut->operandA = a;
  dut->operandB = b;
  dut->command = command;
  dut->eval();
  if (dut->carryout != 0)
    printf("carryout is %d for %d %s %d, should be 0\n",
           dut->carryout, dut->operandA, desc.c_str(), dut->operandB);

  if (dut->overflow != 0)
    printf("overflow is %d for %d %s %d, should be 0\n",
           dut->overflow, dut->operandA, desc.c_str(), dut->operandB);

  if (dut->zero != 0)
    printf("zero is %d for %d %s %d, should be 0\n",
           dut->zero, dut->operandA, desc.c_str(), dut->operandB);
}

/**
 * Given operands and sum, return whether or not there should be a
 * carry.
 * 
 * @param a the first addition operand
 * @param b the second addition operand
 * @return whether or not a carry should have occurred
 */
bool checkCarry(const int a, const int b)
{
  const int sum = a + b;
  if (a < 0 && b < 0) return true;
  if (a < 0 && b >= 0 && sum >= 0) return true;
  if (a >= 0 && b < 0 && sum >= 0) return true;
  return false;
}
/**
 * Warn if the outputs match the result for a bitwise function.
 * This is used in non-addition or subtraction checkers.
 *
 * @param dut the device under testing
 * @param a the dut's operandA.
 * @param b the dut's operandB.
 * @param command the dut's command.
 * @param func the name of the operation carried out
 * @param desc the symbol for the operation carried out
 * @param result the dut's result.
 */
void checkBitwise(Valu* dut, const int a, const int b, const int command, const std::string func, const std::string desc, const int result)
{
  dut->operandA = a;
  dut->operandB = b;
  dut->command = command;
  dut->eval();
  if (dut->result != result)
    printf("%s is %d for %d %s %d, should be %d\n",
           func.c_str(), dut->result, dut->operandA, desc.c_str(), dut->operandB, result);

  flagsZero(dut, a, b, command, "^");
}

/**
 * Warn if the outputs of the dut are incorrect for a sum.
 *
 * @param dut the device under testing
 * @param a the dut's operandA.
 * @param b the dut's operandB.
 */
void checkSum(Valu* dut, const int a, const int b)
{
  dut->operandA = a;
  dut->operandB = b;
  dut->command = 0;
  dut->eval();
  const int operandA = dut->operandA;
  const int operandB = dut->operandB;
  const int sum = operandA + operandB;
  const bool carry = checkCarry(operandA, operandB);
  const bool overflow = operandA >= 0 && operandB >= 0
    ? sum < 0 : (operandA < 0 && operandB < 0 ? sum >= 0 : 0);

  if (dut->result != sum)
    printf("Sum is %d for %d + %d, should be %d\n",
           dut->result, operandA, operandB, sum);

  if (dut->carryout != carry)
    printf("carryout is %d for %d + %d, should be %d\n",
           dut->carryout, operandA, operandB, carry);

  checkZero(dut, a, b, 0, "+");

  if (dut->overflow != overflow)
    printf("Overflow is %d for %d + %d, should be %d\n",
           dut->overflow, operandA, operandB, overflow);
}

/**
 * Warn if the outputs of the dut are incorrect for subtraction.
 *
 * @param dut the device under testing
 * @param a the dut's operandA.
 * @param b the dut's operandB.
 */
void checkDiff(Valu* dut, int a, int b)
{
  dut->operandA = a;
  dut->operandB = b;
  dut->command = 1;
  dut->eval();
  const int operandA = dut->operandA;
  const int operandB = dut->operandB;
  const int diff = operandA - operandB;
  const bool carry = checkCarry(operandA, -operandB);
  const bool zero = diff == 0;
  const bool overflow = operandA >= 0 && operandB < 0
                                                    ? diff < 0 : operandA < 0 && operandB >= 0 ? diff >= 0 : 0;

  if (dut->result != diff)
    printf("Difference is %d for %d - %d, should be %d\n",
           dut->result, operandA, operandB, diff);

  if (dut->carryout != carry)
    printf("carryout is %d for %d - %d, should be %d\n",
           dut->carryout, operandA, operandB, carry);

  checkZero(dut, a, b, 1, "-");

  if (dut->overflow != overflow)
    printf("Overflow is %d for %d - %d, should be %d\n",
           dut->overflow, operandA, operandB, overflow);
}

// Warn for each biwise function and SLT.
void checkXor(Valu* dut, const int a, const int b) {checkBitwise(dut, a, b, 2, "Xor",  "^", a ^ b);}
void checkSLT(Valu* dut, const int a, const int b) {checkBitwise(dut, a, b, 3, "SLT", "<", a < b);}
void checkAnd(Valu* dut, const int a, const int b) {checkBitwise(dut, a, b, 4, "And", "&", a & b);}
void checkNand(Valu* dut, const int a, const int b) {checkBitwise(dut, a, b, 5, "Nand", "NAND", ~(a & b));}
void checkNor(Valu* dut, const int a, const int b) {checkBitwise(dut, a, b, 6, "Nor", "NOR", ~(a | b));}
void checkOr(Valu* dut, const int a, const int b) {checkBitwise(dut, a, b, 7, "Or", "|", a | b);}

/**
 * Generate test cases which match the input criteria.
 * Overflows are handled for when the signs of the input are the same
 * but do not match the sign of the sum
 *
 * @param a_nonneg true iff operandA is desired to be nonnegative.
 * @param b_nonneg true iff operandB is desired to be nonnegative.
 * @param sum_nonneg true iff the sum is desired to be negative.
 * @return a tuple a operandB and operandA which match the input
 * criteria.
 */
std::tuple<int, int> genTestCase(bool a_nonneg, bool b_nonneg, bool sum_nonneg)
{
  std::random_device rd;
  std::mt19937 rng(rd());

  // If a and b are negative but a negative sum is desired a has to be
  // the minimum integer plus 1.
  const int a = a_nonneg ? rand() : - (rand() + (b_nonneg || sum_nonneg));

  std::tuple<int, int> b_range;

  if (a_nonneg == b_nonneg)
    {
      if (sum_nonneg == a_nonneg)
        {
          if (a_nonneg) b_range = {0, std::numeric_limits<int>::max() - a};
          else b_range = {std::numeric_limits<int>::min() - a, -1};
        } else
        {
          if (a_nonneg) b_range = {std::numeric_limits<int>::max() - a + 1, std::numeric_limits<int>::max()};
          else b_range = {std::numeric_limits<int>::min(), std::numeric_limits<int>::min() - a - 1};
        }
    } else
    {
      if (a_nonneg)
        {
          if (sum_nonneg) b_range = {-a, -1};
          else b_range = {std::numeric_limits<int>::min(), -a - 1};
        } else
        {
          if (sum_nonneg) b_range = {-a, std::numeric_limits<int>::max()};
          else b_range = {-a - 1, std::numeric_limits<int>::min() - a};
        }
    }

  int min_b_range = std::min(std::get<0>(b_range), std::get<1>(b_range));
  int max_b_range = std::max(std::get<0>(b_range), std::get<1>(b_range));
  std::uniform_int_distribution<int> uni(min_b_range, max_b_range);

  return {a, uni(rng)};
}

int main(int argc, char** argv)
{
  Verilated::commandArgs(argc, argv);

  Valu* dut = new Valu();
  std::random_device rd;
  std::mt19937 rng(rd());

  const std::vector<void (*) (Valu*, int, int)> test_commands =
    {
     checkSum, checkDiff, checkXor, checkSLT,
     checkAnd, checkNand, checkNor, checkOr
    };

  // Iterate through all test case specs
  for (auto i = 0; i < 8; i++)
    {

      // Randomly select 1024 test cases for each test case spec
      for (auto j = 0; j < 1024; j++)
        {
          const auto test_case = genTestCase(i & 1, bool (i & 2), bool (i & 4));
          const auto b = std::get<1>(test_case);

          // Check each test case for each function
          for (auto k = 0; k < 8; k++)
            {
              dut->operandB = k == 1 ? -b : b;
              test_commands[k](dut, std::get<0>(test_case), k == 1 ? -b : b);

              // Verify zero-flag on.
              const auto rand1 = rand() % 2 ? rand() : -rand();
              const auto rand2 = k == 1 ? dut->operandA : -dut->operandA;
              test_commands[k](dut, rand1, rand2);

              // Test overflow at the minimum and maximum values
              const auto rand3 = rand() % 2 ? rand() : -(rand() + 1);
              const int overflow_b = (rand3 < 0 ? std::numeric_limits<int>::min() : std::numeric_limits<int>::max()) - rand3;
              test_commands[k](dut, rand3, k == 1 ? -overflow_b : overflow_b);
            }
        }
    }

  // Test all combinations of edge values
  int edge_vals[] = {0, -1, std::numeric_limits<int>::min(), std::numeric_limits<int>::max()};

  for (const auto& val0 : edge_vals)
    for (const auto& val1 : edge_vals)
      for (const auto& test_command : test_commands)
        {
          test_command(dut, val0, val1);
        }
  printf("If you see nothing above, then the ALU works! Otherwise, look at the test cases and fix them.\n");
}
