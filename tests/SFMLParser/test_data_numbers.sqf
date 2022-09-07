#include "script_component.hpp"
#define TEST test_data_numbers

LOG_TEST_START;
INIT_FAILED_STEPS_COUNTER;

private _s = ["tests\SFMLParser\data_numbers.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "Int",         1245, "Int type");
    ASSERT_EQUALS_EXP(_s get "Float",       12.345, "Float type");
    ASSERT_EQUALS_EXP(_s get "Scientific",  12.3e4, "Scientific type");
    ASSERT_EQUALS_EXP(_s get "NegInt",      -96, "NegInt type");
    ASSERT_EQUALS_EXP(_s get "NegFloat",    -12.345, "NegFloat type");
    ASSERT_EQUALS_EXP(_s get "Sum",         (2 + 2), "Sum type");
    ASSERT_EQUALS_EXP(_s get "Minus",       (5 - 2), "Minus type");
    ASSERT_EQUALS_EXP(_s get "Multiply",    (5 * 2), "Multiply type");
    ASSERT_EQUALS_EXP(_s get "Div",         (4 / 2), "Div type");
    ASSERT_EQUALS_EXP(_s get "Modulo",      (5 % 2), "Modulo type");
    ASSERT_EQUALS_EXP(_s get "Pow",         (4 ^ 2), "Pow type");
    ASSERT_EQUALS_EXP(_s get "Equation",    (-3 * ((2.36-3)/2 + 2.13 % 2)), "Equation type");
_VALIDATION_END_

// End
if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
