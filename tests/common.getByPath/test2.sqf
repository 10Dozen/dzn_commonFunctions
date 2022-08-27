
#include "script_component.hpp"
#define TEST test2_HashMapKeyDataType

/*  Tests different hashmap keys data types.
*/

INIT_STEP_FAILS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", west, true, { hint "Kek" }, [1,2,3], "Key"];
private _expectedValue = 999;
private _defaultValue = _expectedValue;

private _nestedLast = createHashMapFromArray [["Key", _expectedValue]];
private _nestedKeyArray = createHashMapFromArray [[[1,2,3], _nestedLast]];
private _nestedKeyCode = createHashMapFromArray [[{ hint "Kek" }, _nestedKeyArray]];
private _nestedKeyBool = createHashMapFromArray [[true, _nestedKeyCode]];
private _nestedKeySide = createHashMapFromArray [[west, _nestedKeyBool]];
private _hash = createHashMapFromArray [["NestedA", _nestedKeySide]];

// Test
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
