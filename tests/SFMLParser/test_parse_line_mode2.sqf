#include "script_component.hpp"
#define TEST test_parse_line_mode2

LOG_TEST_START;
INIT_FAILED_STEPS_COUNTER;

// Before
private _expectedMap = createHashMapFromArray [
    ["nilKey", nil],
    ["size", 32]
];

// Test
private _s = ["nilKey: nil, size: 32", "PARSE_LINE"] call dzn_fnc_parseSFML;

if ("nilKey" in keys _s) then {
    private _nil = _s get "nilKey";
    if (!isNil "_nil") then {
        FAIL_STEP;
        ERROR_ "NilKey is present but it's not a nil! Actual: %1", _nil _EOL
    };
} else {
    FAIL_STEP;
    ERROR_ "NilKey is not presenet in resulted hashmap!" _EOL
};

if !("size" in keys _s && {_s get "size" == 32}) then {
    FAIL_STEP;
    ERROR_ "Size key is not parsed properly! Value: %1 vs expected 32.", _s get "size" _EOL;
};

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false;
};

LOG_TEST_PASSED;
true
