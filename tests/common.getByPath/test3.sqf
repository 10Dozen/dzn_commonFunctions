
#include "script_component.hpp"
#define TEST test3_EscapedKeys

/*  Tests parsing of the excaped keys syntax (for > and numeric strings)
*/

INIT_STEP_FAILS_COUNTER;
LOG_TEST_START;

// Before
private _pathStr = "NestedA > '>' > '1337' > Key";
private _pathArr = ["NestedA", ">", '1337', "Key"];
private _expectedValue = 999;

private _nestedC = createHashMapFromArray [["Key", _expectedValue]];
private _nestedB = createHashMapFromArray [['1337', _nestedC]];
private _nestedA = createHashMapFromArray [[">", _nestedB]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

// Test
private _valStr = [_hash, _pathStr] call dzn_fnc_getByPath;

if (isNil "_valStr") then {
    FAIL_STEP;
    ERROR_ "[PathAsString] Value is nil" _EOL;
} else {
    INFO_ "[PathAsString] Value [%1]", _valStr _EOL;
    if (_valStr isNotEqualTo _expectedValue) then {
        FAIL_STEP;
        ERROR_ "[PathAsString] Value [%1] in not queal expected [%2]", _valStr, _expectedValue _EOL;
    };
};

private _valArr = [_hash, _pathArr] call dzn_fnc_getByPath;

if (isNil "_valArr") then {
    FAIL_STEP;
    ERROR_ "[PathAsArray] Value is nil" _EOL;
} else {
    INFO_ "[PathAsArray] Value [%1]", _valArr _EOL;
    if (_valArr isNotEqualTo _expectedValue) then {
        FAIL_STEP;
        ERROR_ "[PathAsArray] Value [%1] in not queal expected [%2]", _valArr, _expectedValue _EOL;
    };
};

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
