
#include "script_component.hpp"
#define TEST test5.2_DefaultValue_Mixed

/*  Test missing end key value and usage of the default value passed to function.
    Path is mixed maps/arrays.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathStr = "NestedA > NestedArray > 12";
private _pathArr = ["NestedA", "NestedArray", 12];
private _expectedValue = 999;
private _defaultValue = _expectedValue;

private _nestedArray = [1,2,3];
private _nestedA = createHashMapFromArray [["NestedArray", _nestedArray]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

// Test
private _valStr = [_hash, _pathStr, _defaultValue] call dzn_fnc_getByPath;

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

private _valArr = [_hash, _pathArr, _defaultValue] call dzn_fnc_getByPath;

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
