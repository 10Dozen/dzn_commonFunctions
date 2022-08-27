#include "script_component.hpp"
#define TEST test_datatypes

LOG_TEST_START;

test_var = 123;
private _s = ["tests\SFMLParser\data_types.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);

if ((_s get ERRORS_NODE) NEQ []) exitWith {
    ERROR_ "There are parsing errors detected!" _EOL;
    LOG_TEST_FAILED;
    false;
};

private _passed = true
&& assert ((_s get "KeyStr") isEqualTo "I am a String")
&& assert ((_s get "KeyStrDoubleQ") isEqualTo "String double quoted")
&& assert ((_s get "KeyStrQ") isEqualTo "String single quote")
&& assert ((_s get "KeyNum") isEqualTo 12)
&& assert ((_s get "KeyNumEq") isEqualTo 39)
&& assert (!(_s get "KeyBoolFalse"))
&& assert ((_s get "KeyBoolTrue"))
&& assert ((_s get "KeyHash") isEqualTo (createHashMapFromArray [["name","John"],["age", 32]]))
&& assert ((_s get "KeyVar") isEqualTo test_var)
&& assert ((_s get "KeyVarImpl") isEqualTo test_var)
&& assert ((_s get "KeySide") isEqualTo east)
&& assert ((_s get "KeyEval") isEqualTo 2)
&& assert ((_s get "KeyCode") isEqualTo { hint "Code"; })
&& assert ((_s get "KeyArray") isEqualTo [1,2,3])
&& assert (isNil {(_s get "KeyNil")} && "KeyNil" in keys _s)
&& assert (isNull (_s get "KeyNull"));

test_var = nil;

if (!_passed) exitWith {
    LOG_TEST_FAILED;
    _false
};

LOG_TEST_PASSED;
true
