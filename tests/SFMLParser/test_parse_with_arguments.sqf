#include "script_component.hpp"
#define TEST test_parse_with_arguments

LOG_TEST_START;
INIT_FAILED_STEPS_COUNTER;

private _args = [
    1337,
    [99, 88],
    createHashMapFromArray [["Foo", "Bar"]]
];

private _s = [
    "tests\SFMLParser\parse_with_arguments.yml",
    "LOAD_FILE",
    _args
] call dzn_fnc_parseSFML;

LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "MyKey", _args # 0, "Simple value argument");
    ASSERT_EQUALS_EXP(_s get "MyArray", _args # 1, "Array argument");
    ASSERT_EQUALS_EXP(_s get "MyHashMap", _args # 2, "HashMap argument");
    ASSERT_EQUALS_EXP(_s get "MyKeyFromArray", _args # 1 # 0, "Array index argument");
    ASSERT_EQUALS_EXP(_s get "MyKeyFromHahMap", (_args # 2) get "Foo", "HashMap key argument");
_VALIDATION_END_

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
