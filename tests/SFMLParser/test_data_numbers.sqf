#include "script_component.hpp"
#define TEST test_data_numbers

LOG_TEST_START;

private _s = ["tests\SFMLParser\data_numbers.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

private _passed = true
&& assert ((_s get "Int") EQ 1245)
&& assert ((_s get "Float") EQ 12.345)
&& assert ((_s get "Scientific") EQ 12.3e4)
&& assert ((_s get "NegInt") EQ -96)
&& assert ((_s get "NegFloat") EQ -12.345)
&& assert ((_s get "Sum") EQ (2 + 2))
&& assert ((_s get "Minus") EQ (5 - 2))
&& assert ((_s get "Multiply") EQ (5*2))
&& assert ((_s get "Div") EQ (4/2))
&& assert ((_s get "Modulo") EQ (5 % 2))
&& assert ((_s get "Pow") EQ (4 ^ 2))
&& assert ((_s get "Equation") EQ (-3 * ((2.36-3)/2 + 2.13 % 2)));

if (!_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
