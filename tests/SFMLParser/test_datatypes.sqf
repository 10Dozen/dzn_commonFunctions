#include "script_component.hpp"
#define TEST test_datatypes

LOG_TEST_START;

test_var = 123;
private _s = ["tests\SFMLParser\data_types.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

private _passed = true
&& assert ((_s get "KeyStr") EQ "I am a String")
&& assert ((_s get "KeyStrDoubleQ") EQ "String double quoted")
&& assert ((_s get "KeyStrQ") EQ "String single quote")
&& assert ((_s get "KeyNum") EQ 12)
&& assert ((_s get "KeyNumEq") EQ 39)
&& assert (!(_s get "KeyBoolFalse"))
&& assert ((_s get "KeyBoolTrue"))
&& assert ((_s get "KeyHash") EQ (createHashMapFromArray [["name","John"],["age", 32]]))
&& assert ((_s get "KeyVar") EQ test_var)
&& assert ((_s get "KeyVarImpl") EQ test_var)
&& assert ((_s get "KeySide") EQ east)
&& assert ((_s get "KeyEval") EQ 2)
&& assert ((_s get "KeyCode") EQ { hint "Code"; })
&& assert ((_s get "KeyArray") EQ [1,2,3])
&& assert (isNil {(_s get "KeyNil")} && "KeyNil" in keys _s)
&& assert (isNull (_s get "KeyNull"));

test_var = nil;

if (!_passed) exitWith {
    LOG_TEST_FAILED;
    _false
};

LOG_TEST_PASSED;
true
