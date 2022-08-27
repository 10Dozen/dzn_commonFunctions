#include "script_component.hpp"
#define TEST __FILE__

LOG_TEST_START;

// Before
private _testFails = [];
test_var = 333;

// Test
[
    ["name: John, age: 32", createHashMapFromArray [
        ["name","John"],
        ["age", 32]
    ]],
    ["name: 'John', age: 30+2, side: west", createHashMapFromArray [
        ["name","John"],
        ["age", 32],
        ["side", west]
    ]],
    ["size: `32 min 16`, bool: false, arr: [1,2,3], var: <test_var>", createHashMapFromArray [
        ["size", 16],
        ["bool", false],
        ["arr", [1,2,3]],
        ["var", test_var]
    ]],
    ["map: (name: John, age: 32, role: [Admin, Player])", createHashMapFromArray [
        ["map", createHashMapFromArray [["name","John"],["age", 32],["role",["Admin","Player"]]]
    ]],
    ["nil: nil, null: objNull", createHashMapFromArray [
        ["nil", nil],
        ["null", objNull]
    ]],
    ["code: { [1,2,3] # 1 }", createHashMapFromArray [
        ["code", { [1,2,3] # 1 }]
    ]]
] apply {
    _x params ["_input", "_expected"];
    INFO_ "Test %1. Input: [%2]. Expected result: %3", _forEachIndex, _input, _expected _EOL;

    private _s = [_input, "PARSE_LINE"] call dzn_fnc_parseSFML;
    LOG_PARSING_ERRORS(_s);

    if ((_s get ERRORS_NODE) NEQ []) exitWith {
        ERROR_ "There are parsing errors detected!" _EOL
        LOG_TEST_FAILED;
        false;
    };

    private _results = (keys _expected) apply {
        (_s get _x) EQ (_expected get _x)
    };

    if (false in _results) then {
        _testFails pushBack false;
        ERROR_ "Test %1 failed!", _forEachIndex _EOL;
    };
};

// After
test_var = nil;

if (_testFails NEQ []) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
