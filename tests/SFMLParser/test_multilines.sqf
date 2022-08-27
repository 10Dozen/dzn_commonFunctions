#include "script_component.hpp"
#define TEST test_multilines

LOG_TEST_START;

private _s = ["tests\SFMLParser\multilines.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
TEST_MAP = _s;

if ((_s get ERRORS_NODE) NEQ []) exitWith {
    ERROR_ "There are parsing errors detected!" _EOL;
    LOG_TEST_FAILED;
    false;
};

private _newline = "This is a text of newlines." + endl
+ "Each lines is a separate line." + endl
+ "" + endl
+ "Empty lines are also a new line." + endl
+ "   extra spaicing is saved.";
private _folded = "This is a single line. Merged by one space symbol.  Empty lines are just empty palce.     extra spacing is saved.";

private _passed = true
&& assert ("Newline" in keys _s)
&& assert ("Folded" in keys _s)
&& assert ("Code" in keys _s)
&& {
    assert ((_s get "Newline") EQ _newline)
    && assert ((_s get "Folded") EQ _folded)
    && assert ([] call (_s get "Code") EQ 2)
};

if (isNil "_passed" || !_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
