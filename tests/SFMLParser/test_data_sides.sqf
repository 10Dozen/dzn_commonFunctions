#include "script_component.hpp"
#define TEST test_data_sides

LOG_TEST_START;

private _s = ["tests\SFMLParser\data_sides.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);

if ((_s get ERRORS_NODE) NEQ []) exitWith {
    ERROR_ "There are parsing errors detected!" _EOL;
    LOG_TEST_FAILED;
    false;
};

private _passed = true
&& assert ((_s get "west") findIf { _x isNotEqualTo west} < 0)
&& assert ((_s get "blufor") findIf { _x isNotEqualTo blufor} < 0)
&& assert ((_s get "east") findIf { _x isNotEqualTo east} < 0)
&& assert ((_s get "opfor") findIf { _x isNotEqualTo opfor} < 0)
&& assert ((_s get "indep") findIf { _x isNotEqualTo resistance} < 0)
&& assert ((_s get "independent") findIf { _x isNotEqualTo resistance} < 0)
&& assert ((_s get "resistance") findIf { _x isNotEqualTo resistance} < 0)
&& assert ((_s get "guer") findIf { _x isNotEqualTo resistance} < 0)
&& assert ((_s get "civilian") findIf { _x isNotEqualTo civilian} < 0)
&& assert ((_s get "civ") findIf { _x isNotEqualTo civilian} < 0);

if (!_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
