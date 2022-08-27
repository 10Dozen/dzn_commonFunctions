#include "script_component.hpp"
#define TEST test_data_sides

LOG_TEST_START;

private _s = ["tests\SFMLParser\data_sides.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

private _passed = true
&& assert ((_s get "west") findIf { _x NEQ west} < 0)
&& assert ((_s get "blufor") findIf { _x NEQ blufor} < 0)
&& assert ((_s get "east") findIf { _x NEQ east} < 0)
&& assert ((_s get "opfor") findIf { _x NEQ opfor} < 0)
&& assert ((_s get "indep") findIf { _x NEQ resistance} < 0)
&& assert ((_s get "independent") findIf { _x NEQ resistance} < 0)
&& assert ((_s get "resistance") findIf { _x NEQ resistance} < 0)
&& assert ((_s get "guer") findIf { _x NEQ resistance} < 0)
&& assert ((_s get "civilian") findIf { _x NEQ civilian} < 0)
&& assert ((_s get "civ") findIf { _x NEQ civilian} < 0);

if (!_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
