#include "script_component.hpp"
#define TEST test_references

LOG_TEST_START;

private _s = ["tests\SFMLParser\references.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

private _passed = true
&& assert ((_s get "RefToRoot") EQ 1337)
&& assert ((_s get "RefToNested") EQ 999)
&& assert ((_s get "NestedX" get "NestedY" get "NestedZ" get "NestedRefToNested") EQ 999)
&& assert ((_s get "RefToArr") EQ 435)
&& assert ((_s get "RefToArrayObjects") EQ "Alice")

&& assert ((_s get "RefInArray") # 1 EQ 1337)
&& assert ((_s get "RefInArray") # 3 EQ 435)
&& assert ((_s get "RefInArray") # 4 EQ 999);

if (isNil "_passed" || !_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
