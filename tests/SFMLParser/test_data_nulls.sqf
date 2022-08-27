#include "script_component.hpp"
#define TEST test_data_nulls

LOG_TEST_START;

private _s = ["tests\SFMLParser\data_sides.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);

if ((_s get ERRORS_NODE) NEQ []) exitWith {
    ERROR_ "There are parsing errors detected!" _EOL;
    LOG_TEST_FAILED;
    false;
};

private _passed = true
&& assert ((_s get "objNull") isEqualTo objNull)
&& assert ((_s get "grpNull") isEqualTo grpNull)
&& assert ((_s get "locationNull") isEqualTo locationNull);


if (!_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
