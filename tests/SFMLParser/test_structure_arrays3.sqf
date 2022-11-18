
#include "script_component.hpp"
#define TEST test_structure_arrays3

LOG_TEST_START;
INIT_FAILED_STEPS_COUNTER;

private _s = [
    "tests\SFMLParser\structure_arrays3.yml"
] call dzn_fnc_parseSFML;

LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

_VALIDATION_
    ASSERT_EQUALS_EXP(((_s get "Array") # 0 get "name"), "Foo", "Array nested hashmap key 1");
    ASSERT_EQUALS_EXP(((_s get "Array") # 0 get "val"), "Bar", "Array nested hashmap key 2");
    ASSERT_EQUALS_EXP(_s get "RootKey", "Yammy", "Root key after array with nested hashmap");
    ASSERT_EQUALS_EXP(((_s get "Array2") # 0), 1, "Simple array in root after");
    ASSERT_EQUALS_EXP(((_s get "Array2") # 1), 2, "Simple array in root after, second element");
    ASSERT_EQUALS_EXP(_s get "RootKey2", "Yammy2", "Simple key in the tail");

    ASSERT_EQUALS_EXP(((_s get "RootKey3" get "NestedArray1") # 0) get "name", "Alice", "Object Array nested into section");
    ASSERT_EQUALS_EXP(((_s get "RootKey3" get "NestedArray1") # 0) get "age", 30, "Object Array nested into section");
    ASSERT_EQUALS_EXP((_s get "RootKey3" get "NestedKey") get "Foo", "Bar", "NestedKey after Nested array inside section");

    ASSERT_EQUALS_EXP(((_s get "RootKey3" get "NestedArray2") # 0) get "size", "XL", "Object Array nested into section, 1st key");
    ASSERT_EQUALS_EXP(((_s get "RootKey3" get "NestedArray2") # 0) get "red", "XL", "Object Array nested into section, 2nd key");
    ASSERT_EQUALS_EXP((_s get "RootKey3" get "NestedArray3"), [100, 200], "Nested array after Array nested into section");
_VALIDATION_END_

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
