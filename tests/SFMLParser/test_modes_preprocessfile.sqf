#include "script_component.hpp"
#define TEST test_modes_preprocessfile

LOG_TEST_START;
INIT_FAILED_STEPS_COUNTER;

// Mode: Load file
private _src = "tests\SFMLParser\modes_preprocess.yml";
private _s = [_src, "PREPROCESS_FILE"] call dzn_fnc_parseSFML;

LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

private _keys = keys _s;

private _r = true
    && assert ("#SOURCE" in _keys)
    && { assert ((_s get "#SOURCE") EQ _src) };

if (isNil "_r" || !_r) then {
    FAIL_STEP;
    ERROR_ "(PREPROCESS_FILE) Source is invalid. Actual: [%1], but expected [%2]", _s get SOURCE_NODE, _src _EOL;
};

_r = true
    && assert ("Key" in _keys) && { (_s get "Key") EQ 1 }
    && assert ("Section" in _keys)
        && {
             "Key" in (keys (_s get "Section"))
             && { (_s get "Section" get "Key") EQ 2}
       }
    && assert ("Array" in _keys) && { (_s get "Array") EQ [1,2,3] };

if (isNil "_r" || !_r) then {
    FAIL_STEP;
    ERROR_ "(PREPROCESS_FILE) Keys/values are invalid!" _EOL;
};

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true