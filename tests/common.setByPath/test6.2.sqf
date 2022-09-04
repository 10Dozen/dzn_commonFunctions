
#include "script_component.hpp"
#define TEST test6.2_FalseOnMissingNode_Mixed

/*  Test false result when missing middle node.
    Path is mixed maps/arrays.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", 4, 12];
private _expectedValue = 999;

private _nestedArray = [1,2];
private _hash = createHashMapFromArray [["NestedA", _nestedArray]];

// Test
private _result = [_hash, _pathArr, _expectedValue] call dzn_fnc_setByPath;

_VALIDATION_
    ASSERT_NOT_NIL(_result);
    ASSERT_FALSE(_result, "Result is not false!");
_VALIDATION_END_

// Finish
if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
