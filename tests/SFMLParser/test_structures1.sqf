#include "script_component.hpp"
#define TEST test_structures1

LOG_TEST_START;

private _s = ["tests\SFMLParser\structures1.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

private _passed = true
&& assert ((_s get "Plain") EQ [1,2,3])
&& assert ((_s get "Nested") EQ [[1,2,3],[4,5,6],[7,8,9]])
&& assert ((_s get "Oneliner") EQ [1,2,3])
&& assert ((_s get "NestedInOneliner") EQ [[1,2,3], [4,5,6]])

&& assert (((_s get "NestedInObject") # 0 get "key1") EQ 1)
&& assert (((_s get "NestedInObject") # 0 get "arr") EQ [1,2,3])
&& assert (((_s get "NestedInObject") # 1 get "key2") EQ 2)

&& assert (((_s get "NestedInObject2") # 0 get "arr") EQ [1,2,3])
&& assert (((_s get "NestedInObject2") # 0 get "key1") EQ 1)
&& assert (((_s get "NestedInObject2") # 1 get "key2") EQ 2)

&& assert (((_s get "ArrayOfObjects") # 0 get "callsign") EQ "PAPA BEAR")
&& assert (((_s get "ArrayOfObjects") # 1 get "callsign") EQ "Spearhead-1")
&& assert (((_s get "ArrayOfObjects") # 1 get "unit") EQ "spearhead")
&& assert (((_s get "ArrayOfObjects") # 2 get "callsign") EQ "CCP")

&& assert (((_s get "ArrayOfObjects2") # 0 get "a") EQ 1)
&& assert (((_s get "ArrayOfObjects2") # 0 get "b") EQ 2)
&& assert (((_s get "ArrayOfObjects2") # 1 get "c") EQ 3)

&& assert (((_s get "ArrayOfObjects3") # 0 get "a") EQ 1)
&& assert (((_s get "ArrayOfObjects3") # 1 get "b") EQ 2)
&& assert (((_s get "ArrayOfObjects3") # 1 get "c") EQ 3);


if (isNil "_passed" || !_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
