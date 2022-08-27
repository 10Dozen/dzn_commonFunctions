#include "script_component.hpp"
#define TEST test_data_nulls

LOG_TEST_START;

private _s = ["tests\SFMLParser\data_sides.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

private _passed = true
&& assert ((_s get "objNull") EQ objNull)
&& assert ((_s get "grpNull") EQ grpNull)
&& assert ((_s get "locationNull") EQ locationNull);


if (!_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
