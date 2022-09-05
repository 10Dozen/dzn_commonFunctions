
#include "script_component.hpp"
#define TEST test5.2_DefaultValue_Mixed

/*  Test missing end key value and usage of the default value passed to function.
    Path is mixed maps/arrays.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", "NestedArray", 12];
private _expectedValue = 999;
private _defaultValue = _expectedValue;

private _nestedArray = [1,2,3];
private _nestedA = createHashMapFromArray [["NestedArray", _nestedArray]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

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
