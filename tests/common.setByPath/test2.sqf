
#include "script_component.hpp"
#define TEST test2_HashMapKeyDataType

/*  Tests different hashmap keys data types.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

// Before
private _pathArr = ["NestedA", west, true, { hint "Kek" }, [1,2,3], "Key"];
private _expectedValue = 999;
private _defaultValue = _expectedValue;

private _nestedLast = createHashMapFromArray [["Key", 111]];
private _nestedKeyArray = createHashMapFromArray [[[1,2,3], _nestedLast]];
private _nestedKeyCode = createHashMapFromArray [[{ hint "Kek" }, _nestedKeyArray]];
private _nestedKeyBool = createHashMapFromArray [[true, _nestedKeyCode]];
private _nestedKeySide = createHashMapFromArray [[west, _nestedKeyBool]];
private _hash = createHashMapFromArray [["NestedA", _nestedKeySide]];

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
