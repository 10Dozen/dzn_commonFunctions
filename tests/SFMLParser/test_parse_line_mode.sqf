#include "script_component.hpp"
#define TEST test_parse_line_mode

LOG_TEST_START;
INIT_FAILED_STEPS_COUNTER;

// Before
test_var = 333;

// Test
private _index = 1;
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
        ["map", createHashMapFromArray [
            ["name","John"],
            ["age", 32],
            ["role",["Admin","Player"]]
        ]]
    ]],
    ["null: objNull, grp: grpNull", createHashMapFromArray [
        ["null", objNull],
        ["grp", grpNull]
    ]],
    ["code: { [1,2,3] # 1 }", createHashMapFromArray [
        ["code", { [1,2,3] # 1 }]
    ]]
] apply {
    _x params ["_input", "_expected"];
    INFO_ "Test %1. Input: [%2]. Expected result: %3", _index, _input, _expected _EOL;

    private _s = [_input, "PARSE_LINE"] call dzn_fnc_parseSFML;
    LOG_PARSING_ERRORS(_s);
    FAIL_IF_PARSING_ERRORS(_s);

    private _results = (keys _expected) apply {
        INFO_ "  Checking for key [%1]", _x _EOL;
        private _keyExists = _x in keys _s;
        INFO_ "    Key exists? %1", _keyExists _EOL;

        private _expectedValue = _expected get _x;
        private _actualValue = _s get _x;
        INFO_ "    Expected: %1", _expectedValue _EOL;
        INFO_ "    Actual:   %1", _actualValue _EOL;
        _keyExists && {
            !isNil "_actualValue" &&
            { _actualValue EQ _expectedValue }
        }
    };

    if (false in _results) then {
        FAIL_STEP;
        ERROR_ "Test %1 failed!", _index _EOL;
    } else {
        INFO_ "Test %1 passed!", _index _EOL;
    };

    _index = _index + 1;
};

// After
test_var = nil;

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
