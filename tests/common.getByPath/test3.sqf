
#include "script_component.hpp"
#define TEST test3_EscapedKeys

/*  Tests parsing of the excaped keys syntax (for > and numeric strings)
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", ">", '1337', "Key"];
private _expectedValue = 999;

private _nestedC = createHashMapFromArray [["Key", _expectedValue]];
private _nestedB = createHashMapFromArray [['1337', _nestedC]];
private _nestedA = createHashMapFromArray [[">", _nestedB]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

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