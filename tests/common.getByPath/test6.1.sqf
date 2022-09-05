
#include "script_component.hpp"
#define TEST test6.1_DefaultOnMissing_HashMaps

/*  Test missing middle node and usage of the default value passed to function
    Path is maps only..
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", "NestedB", "Key"];
private _expectedValue = 999;
private _defaultValue = _expectedValue;

private _nestedA = createHashMapFromArray [["NestedC", _nestedB]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

// Test
private _val = [_hash, _pathArr, 12, _defaultValue] call dzn_fnc_getByPath;

_VALIDATION_
    ASSERT_NOT_NIL(_val);
    ASSERT_EQUALS(_val, _expectedValue);
_VALIDATION_END_

// Finish
if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
