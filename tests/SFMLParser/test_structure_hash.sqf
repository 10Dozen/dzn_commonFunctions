#include "script_component.hpp"
#define TEST test_structure_hash

LOG_TEST_START;

private _s = ["tests\SFMLParser\structure_hash.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);

if ((_s get ERRORS_NODE) NEQ []) exitWith {
    ERROR_ "There are parsing errors detected!" _EOL;
    LOG_TEST_FAILED;
    false
};

private _passed = true
&& assert ((_s get "Plain" get "Key1") EQ 5000)
&& assert ((_s get "Plain" get "Key2") EQ 35000)

&& assert ((_s get "Nested" get "Section" get "Key1") EQ 100)
&& assert ((_s get "Nested" get "Section" get "Key2") EQ 200)
&& assert ((_s get "Nested" get "Key3") EQ 300)

&& assert ((_s get "Nested2" get "Key1") EQ 100)
&& assert ((_s get "Nested2" get "Key2") EQ 200)
&& assert ((_s get "Nested2" get "Section" get "Key3") EQ 300)

&& assert (((_s get "NestedInArray") # 1 get "name") EQ "John")
&& assert (((_s get "NestedInArray") # 1 get "age") EQ 32)

&& assert (((_s get "NestedInArray2") # 2 get "name") EQ "John")
&& assert (((_s get "NestedInArray2") # 2 get "age") EQ 32)

&& assert (((_s get "NestedInArray3") # 0 get "name") EQ "John")
&& assert (((_s get "NestedInArray3") # 0 get "age") EQ 32)

&& assert ((_s get "Oneliner" get "name") EQ "John")
&& assert ((_s get "Oneliner" get "age") EQ 32)
&& assert ((_s get "Oneliner" get "roles") EQ ["Admin", "GSO"]);

if (!_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
