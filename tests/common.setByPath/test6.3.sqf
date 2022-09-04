
#include "script_component.hpp"
#define TEST test6.3_FalseOnMissingNode_Arrays

/*  Test false result on missing middle node.
    Path is all arrays.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathStr = "3 > 9 > 12";
private _pathArr = [3, 9, 12];
private _expectedValue = 999;

private _array1 = [1,2,3];
private _hash = [0,1,2,_array1];

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
