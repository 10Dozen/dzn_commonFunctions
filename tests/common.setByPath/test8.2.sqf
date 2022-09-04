
#include "script_component.hpp"
#define TEST test8.2_CreateNodeOnMissing_HashMap_in_Array

/*  Test creation of the missing HashMap node nested in array.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = [3, "NestedB", "Key"];
private _expectedValue = 999;

private _hash = [1, 2, 3, createHashMap];

// Test
private _result = [_hash, _pathArr, _expectedValue, true] call dzn_fnc_setByPath;

_VALIDATION_
    ASSERT_NOT_NIL(_result);
    ASSERT_TRUE(_result, "Result is false! Operation failed!");
_VALIDATION_END_

private _val = [_hash, _pathArr] call dzn_fnc_getByPath;

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
