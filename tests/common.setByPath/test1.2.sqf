
#include "script_component.hpp"
#define TEST test1.2_MixedChain

/* Tests access to key when path is mixed hashmaps & arrays
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", "NestedArray", 2];
private _expectedValue = 999;

private _nestedArray = [1, 2, 111];
private _nestedA = createHashMapFromArray [["NestedArray", _nestedArray]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

// Test
private _result = [_hash, _pathArr, _expectedValue] call dzn_fnc_setByPath;
private _val = [_hash, _pathArr] call dzn_fnc_getByPath;

_VALIDATION_
    ASSERT_NOT_NIL(_result);
    ASSERT_TRUE(_result, "Result is false! Operation failed!");
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
