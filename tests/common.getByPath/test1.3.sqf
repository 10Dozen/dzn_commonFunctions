
#include "script_component.hpp"
#define TEST test1.3_ArraysChain

/* Tests access to key when path is chain of arrays
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = [2, 3, 2];
private _expectedValue = 999;

private _array2 = [0,1,_expectedValue];
private _array1 = [0,1,2,_array2];
private _hash = [0,1,_array1];

// Test
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
