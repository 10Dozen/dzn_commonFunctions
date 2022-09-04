
#include "script_component.hpp"
#define TEST test7.4_CreateKeyOnMissing_ArraysPushBack

/*  Test creation of the key on missing. PushBack.
    Path is all arraysy.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = [3, 2, -1];
private _expectedValue = 999;

private _array2 = [1,2,3];
private _array1 = [1,2,_array2];
private _hash = [1,2,3,_array1];

private _pathArrExpected = [3,2,count _array2];

// Test
private _result = [_hash, _pathArr, _expectedValue, true] call dzn_fnc_setByPath;
private _val = [_hash, _pathArrExpected] call dzn_fnc_getByPath;

_VALIDATION_
    ASSERT_NOT_NIL(_result);
    ASSERT_TRUE(_result, "Result is false! Operation failed...");
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
