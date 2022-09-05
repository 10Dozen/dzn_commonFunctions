
#include "script_component.hpp"
#define TEST test5.3_DefaultValue_Arrays

/*  Test missing end key value and usage of the default value passed to function.
    Path is all arrays.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = [3, 2, 12];
private _expectedValue = 999;
private _defaultValue = _expectedValue;

private _array2 = [1,2,3];
private _array1 = [1,2,_array2];
private _hash = [1,2,3,_array1];

// Test
private _val = [_hash, _pathArr, _defaultValue] call dzn_fnc_getByPath;

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
