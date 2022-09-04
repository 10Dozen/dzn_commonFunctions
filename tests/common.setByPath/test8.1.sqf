
#include "script_component.hpp"
#define TEST test8.1_CreateNodeOnMissing_HashMap_in_HashMaps

/*  Test creation of the missing HashMap node in chain.
    Path is maps only.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", "NestedB", "Key"];
private _expectedValue = 999;

private _hash = createHashMapFromArray [["NestedA", createHashMap]];

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
