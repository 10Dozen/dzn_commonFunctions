#include "script_component.hpp"
#define TEST test_empty_input

LOG_TEST_START;
INIT_FAILED_STEPS_COUNTER;
_currentFails = 0;

// ----------
// PARSE_LINE
// ----------
private _s = ["", "PARSE_LINE"] call dzn_fnc_parseSFML;
_VALIDATION_
    if (((_s get "#ERRORS") # 0) isNotEqualTo ["ERR_FILE_EMPTY",-1,"","File is empty!"]) exitWith {
        FAIL_STEP;
        ERROR_ "Wrong error message on empty line in PARSE_LINE mode" _EOL;
        ERROR_ (_s get "#ERRORS") _EOL;
    };
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Empty PARSE_LINE tests failed!" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Empty PARSE_LINE tests passed!" _EOL;
};

// ----------
// LOAD_FILE
// ----------
_currentFails = _fails;
private _s = ["tests\SFMLParser\empty.yml", "LOAD_FILE"] call dzn_fnc_parseSFML;
_VALIDATION_
    if (((_s get "#ERRORS") # 0) isNotEqualTo ["ERR_FILE_EMPTY",-1,"","File is empty!"]) exitWith {
        FAIL_STEP;
        ERROR_ "Wrong error message on empty line in LOAD_FILE mode" _EOL;
        ERROR_ (_s get "#ERRORS") _EOL;
    };
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Empty LOAD_FILE tests failed!" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Empty LOAD_FILE tests passed!" _EOL;
};

// ----------
// PREPROCESS_FILE
// ----------
_currentFails = _fails;
private _s = ["tests\SFMLParser\empty.yml", "PREPROCESS_FILE"] call dzn_fnc_parseSFML;
_VALIDATION_
    if (((_s get "#ERRORS") # 0) isNotEqualTo ["ERR_FILE_EMPTY",-1,"","File is empty!"]) exitWith {
        FAIL_STEP;
        ERROR_ "Wrong error message on empty line in PREPROCESS_FILE mode" _EOL;
        ERROR_ (_s get "#ERRORS") _EOL;
    };
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Empty PREPROCESS_FILE tests failed!" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Empty PREPROCESS_FILE tests passed!" _EOL;
};

// End
if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
