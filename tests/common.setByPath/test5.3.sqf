
#include "script_component.hpp"
#define TEST test5.3_FalseOnMissingKey_Arrays

/*  Test false result on missing end key value.
    Path is all arrays.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = [3, 2, 12];
private _expectedValue = 999;

private _array2 = [1,2,3];
private _array1 = [1,2,_array2];
private _hash = [1,2,3,_array1];

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
