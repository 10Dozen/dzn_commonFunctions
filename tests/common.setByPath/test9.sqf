
#include "script_component.hpp"
#define TEST test9_SetDataTypes

/*  Test set of different data types
*/

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;
private _idx = 0;

private _pathArr = ["NestedA", "NestedB", "Key"];
private _nestedB = createHashMapFromArray [["Key", -1]];
private _nestedA = createHashMapFromArray [["NestedB", _nestedB]];
private _hash = createHashMapFromArray [["NestedA", _nestedA]];

[
    999,
    "String value",
    true,
    west,
    group player,
    player,
    [1,2,3,4],
    createHashMapFromArray [["K", 1], ["D", 2]],
    controlNull,
    displayNull,
    parseText "Parsed text",
    { hint "HEHE"; },
    missionNamespace
] apply {
    _idx = _idx + 1;
    INFO_ "Test Group %1: %2 => %3", _idx, _pathArr, _x _EOL;

    private _expectedValue = _x;

    private _result = [_hash, _pathArr, _expectedValue] call dzn_fnc_setByPath;
    _VALIDATION_
        ASSERT_NOT_NIL(_result);
        ASSERT_TRUE(_result, "Operation failed!");
    _VALIDATION_END_

    private _val = [_hash, _pathArr] call dzn_fnc_getByPath;
    _VALIDATION_
        ASSERT_NOT_NIL(_val);
        ASSERT_EQUALS(_val, _expectedValue);
    _VALIDATION_END_
};

// Finish
if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
