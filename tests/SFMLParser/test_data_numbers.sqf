#include "script_component.hpp"
#define TEST test_data_numbers

LOG_TEST_START;

private _s = ["tests\SFMLParser\data_numbers.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);

if ((_s get ERRORS_NODE) NEQ []) exitWith {
    ERROR_ "There are parsing errors detected!" _EOL;
    LOG_TEST_FAILED;
    false;
};

private _passed = true
&& assert ((_s get "Int") isEqualTo 1245)
&& assert ((_s get "Float") isEqualTo 12.345)
&& assert ((_s get "Scientific") isEqualTo 12.3e4)
&& assert ((_s get "NegInt") isEqualTo -96)
&& assert ((_s get "NegFloat") isEqualTo -12.345)
&& assert ((_s get "Sum") isEqualTo (2 + 2))
&& assert ((_s get "Minus") isEqualTo (5 - 2))
&& assert ((_s get "Multiply") isEqualTo (5*2))
&& assert ((_s get "Div") isEqualTo (4/2))
&& assert ((_s get "Modulo") isEqualTo (5 % 2))
&& assert ((_s get "Pow") isEqualTo (4 ^ 2))
&& assert ((_s get "Equation") isEqualTo (-3 * ((2.36-3)/2 + 2.13 % 2)));

if (!_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
