
#include "script_component.hpp"
#define TEST test6.2_DefaultOnMissing_Mixed

/*  Test missing middle node and usage of the default value passed to function.
    Path is mixed maps/arrays.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", 4, 12];
private _expectedValue = 999;
private _defaultValue = _expectedValue;

private _nestedArray = [1,2];
private _hash = createHashMapFromArray [["NestedA", _nestedArray]];

// Test
private _val = [_hash, _pathArr, 12, _expectedValue] call dzn_fnc_getByPath;

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
