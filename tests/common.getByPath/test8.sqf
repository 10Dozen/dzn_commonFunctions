
#include "script_component.hpp"
#define TEST test8_EmptyPath

/* Tests empty path handling.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;
private _idx = 0;

// Before
private _pathArr = [];
private _expectedValue = 999;
private _defaultOnMissingValue = _expectedValue;

private _nestedA = createHashMapFromArray [["NestedB", 1]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

// Test
// - no default - expected nil
private _val = [_hash, _pathArr] call dzn_fnc_getByPath;

_VALIDATION_
    ASSERT_NIL(_val);
_VALIDATION_END_

// - default defined - default expected
_val = [_hash, _pathArr, 111, _defaultOnMissingValue] call dzn_fnc_getByPath;
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
