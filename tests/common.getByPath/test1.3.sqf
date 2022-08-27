
#include "script_component.hpp"
#define TEST test1.3_ArraysChain

/* Tests access to key when path is chain of arrays
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathStr = "2 > 3 > 2";
private _pathArr = [2, 3, 2];
private _expectedValue = 999;

private _array2 = [0,1,_expectedValue];
private _array1 = [0,1,2,_array2];
private _hash = [0,1,_array1];

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
