
#include "script_component.hpp"
#define TEST test3_FalsOnNilNode

/*  Tests false result if middle node is nil
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", "NestedB", "Key"];
private _expectedValue = 999;
private _defaultValue = _expectedValue;

private _nestedA = createHashMapFromArray [["NestedB", nil]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

// Test
private _result = [_hash, _pathArr, _expectedValue] call dzn_fnc_setByPath;

_VALIDATION_
    ASSERT_NOT_NIL(_result);
    ASSERT_FALSE(_result, "Result is not false! Operation failed!");
_VALIDATION_END_

// Finish
if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true