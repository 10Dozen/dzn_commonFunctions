#include "script_component.hpp"
#define TEST test_structure_hash

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

private _s = ["tests\SFMLParser\structure_hash.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

TEST_MAP = _s;

_VALIDATION_

    ASSERT_EQUALS_EXP(_s get "Plain" get "Key1", 5000, "Plain Key1");
    ASSERT_EQUALS_EXP(_s get "Plain" get "Key2", 35000, "Plain Key2");

    ASSERT_EQUALS_EXP(_s get "Nested" get "Section" get "Key1", 100, "Nested - Section - Key1");
    ASSERT_EQUALS_EXP(_s get "Nested" get "Section" get "Key2", 200, "Nested - Section - Key2");
    ASSERT_EQUALS_EXP(_s get "Nested" get "Key3", 300, "Nested - Key3");

    ASSERT_EQUALS_EXP(_s get "Nested2" get "Key1", 100, "Nested2 - Key1");
    ASSERT_EQUALS_EXP(_s get "Nested2" get "Section" get "Key2", 200, "Nested2 - Section - Key2");
    ASSERT_EQUALS_EXP(_s get "Nested2" get "Section" get "Key3", 300, "Nested2 - Section - Key3");

    ASSERT_EQUALS_EXP(_s get "Nested3" get "Key1", 100, "Nested3 - Key1");
    ASSERT_EQUALS_EXP(_s get "Nested3" get "Key2", 200, "Nested3 - Key2");
    ASSERT_EQUALS_EXP(_s get "Nested3" get "Section" get "Key3", 300, "Nested3 - Section - Key2");

    ASSERT_EQUALS_EXP((_s get "NestedInArray") # 1 get "name", "John", "NestedInArray - 1 - name");
    ASSERT_EQUALS_EXP((_s get "NestedInArray") # 1 get "age", 32, "NestedInArray - 1 - age");

    ASSERT_EQUALS_EXP((_s get "NestedInArray2") # 2 get "name", "John", "NestedInArray2 - 2 - name");
    ASSERT_EQUALS_EXP((_s get "NestedInArray2") # 2 get "age", 32, "NestedInArray2 - 2 - age");

    ASSERT_EQUALS_EXP((_s get "NestedInArray3") # 0 get "name", "John", "NestedInArray3 - 0 - name");
    ASSERT_EQUALS_EXP((_s get "NestedInArray3") # 0 get "age", 32, "NestedInArray3 - 0 - age");

    ASSERT_EQUALS_EXP(_s get "Oneliner" get "name", "John", "Oneliner - name");
    ASSERT_EQUALS_EXP(_s get "Oneliner" get "age", 32, "Oneliner - age");

    ASSERT_EQUALS_EXP(_s get "Oneliner" get "roles", [ARR_2("Admin", "GSO")], "Oneliner - roles");

_VALIDATION_END_

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
ASSERT_EQUALS_EXP
