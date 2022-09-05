
#include "script_component.hpp"
#define TEST test7.1_NilOnNotNil

/*  Test nil result if key in the middle contain nil value.
    Path is maps only..
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", "NestedB", "Key"];
private _expectedValue = 999;
private _defaultValue = _expectedValue;

private _nestedA = createHashMapFromArray [["NestedC", nil]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

// Test
private _val = [_hash, _pathArr] call dzn_fnc_getByPath;

_VALIDATION_
    ASSERT_NIL(_val);
_VALIDATION_END_

// Finish
if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
