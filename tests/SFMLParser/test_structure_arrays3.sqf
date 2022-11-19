
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
    ASSERT_EQUALS_EXP(((_s get "Array") # 0 get "name"), "Foo", "A1: Array nested hashmap key 1");
    ASSERT_EQUALS_EXP(((_s get "Array") # 0 get "val"), "Bar", "A2: Array nested hashmap key 2");
    ASSERT_EQUALS_EXP(_s get "RootKey", "Yammy", "A3: Root key after array with nested hashmap");
    ASSERT_EQUALS_EXP(((_s get "Array2") # 0), 1, "A4: Simple array in root after");
    ASSERT_EQUALS_EXP(((_s get "Array2") # 1), 2, "A5: Simple array in root after, second element");
    ASSERT_EQUALS_EXP(_s get "RootKey2", "Yammy2", "A6: Simple key in the tail");

    ASSERT_EQUALS_EXP(((_s get "RootKey3" get "NestedArray1") # 0) get "name", "Alice", "B1: Object Array nested into section");
    ASSERT_EQUALS_EXP(((_s get "RootKey3" get "NestedArray1") # 0) get "age", 30, "B2: Object Array nested into section");
    ASSERT_EQUALS_EXP((_s get "RootKey3" get "NestedKey") get "Foo", "Bar", "B3: NestedKey after Nested array inside section");

    ASSERT_EQUALS_EXP(((_s get "RootKey4" get "NestedArray2") # 0) get "size", "XL", "C1: Object Array nested into section, 1st key");
    ASSERT_EQUALS_EXP(((_s get "RootKey4" get "NestedArray2") # 0) get "color", "red", "C2: Object Array nested into section, 2nd key");
    ASSERT_EQUALS_EXP((_s get "RootKey4" get "NestedArray3"), [100, 200], "C3: Nested array after Array nested into section");

    ASSERT_EQUALS_EXP(((_s get "RootKey4" get "Subsection" get "SubKey") # 0) get "x", "y", "D1: Section > Subsection > Array > Nested hash, 1st element");
    ASSERT_EQUALS_EXP(((_s get "RootKey4" get "Subsection" get "SubKey") # 1) get "x", "z", "D2: Section > Subsection > Array > Nested hash, 2nd element");
    ASSERT_EQUALS_EXP(((_s get "RootKey4" get "Subsection" get "SubKey") # 2) get "x", "w", "D3: Section > Subsection > Array > Nested hash, 3rd element, 1st key");
    ASSERT_EQUALS_EXP(((_s get "RootKey4" get "Subsection" get "SubKey") # 2) get "type", 1, "D4: Section > Subsection > Array > Nested hash, 3rd element, 2nd key");
    ASSERT_EQUALS_EXP(((_s get "RootKey4" get "Subsection" get "SubKey") # 3) get "x", "q", "D5: Section > Subsection > Array > Nested hash, 4th element");

    ASSERT_EQUALS_EXP((_s get "RootKey4" get "NestedKey1"), "Echo", "E1: Section > Subsection > Key, after nested subsection with array");
_VALIDATION_END_

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
