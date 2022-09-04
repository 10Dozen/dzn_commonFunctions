
#include "script_component.hpp"
#define TEST test8.3_CreateNodeOnMissing_Array_in_HashMap

/*  Test creation of the missing array node nested in HashMap.
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;
private _idx = 1;

// Before
[
    {
        private _hash = createHashMapFromArray [["NestedArr", [1,2,3]]];
        [_hash, ["NestedArr", "4[]", 2], ["NestedArr", 4, 2], 999]
    },
    {
        private _hash = createHashMapFromArray [["NestedArr", [1,2,3]]];
        [_hash, ["NestedArr", "[]", 2], ["NestedArr", 3, 2], 999]
    },
    {
        private _hash = createHashMapFromArray [["NestedArr", [1,2,3]]];
        [_hash, ["NestedArr", "[]", -1], ["NestedArr", 3, 0], 999]
    }
] apply {
    (call _x) params ["_hash", "_pathSet", "_pathGet", "_expectedValue"];

    INFO_ "Test group %1: %2 vs %3", _idx, _pathSet, _pathGet _EOL;

    // Test
    private _result = [_hash, _pathSet, _expectedValue, true] call dzn_fnc_setByPath;

    INFO_ "After: %1", _hash _EOL;

    _VALIDATION_
        ASSERT_NOT_NIL(_result);
        ASSERT_TRUE(_result, "Result is false! Operation failed!");
    _VALIDATION_END_

    private _val = [_hash, _pathGet] call dzn_fnc_getByPath;

    _VALIDATION_
        ASSERT_NOT_NIL(_val);
        ASSERT_EQUALS(_val, _expectedValue);
    _VALIDATION_END_

    _idx = _idx + 1;
};
// Finish
if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
