
#include "script_component.hpp"
#define TEST test5.1_FalseOnMissingKey_HashMaps

/*  Test false result on missing end key in path.
    Path is maps only..
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", "NestedB", "Key"];
private _expectedValue = 999;

private _nestedB = createHashMapFromArray [["Key2", 13]];
private _nestedA = createHashMapFromArray [["NestedB", _nestedB]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

// Test
private _result = [_hash, _pathArr, _expectedValue] call dzn_fnc_setByPath;

_VALIDATION_
    ASSERT_NOT_NIL(_result);
    ASSERT_FALSE(_result, "Result is not false!");
_VALIDATION_END_

// End
if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
