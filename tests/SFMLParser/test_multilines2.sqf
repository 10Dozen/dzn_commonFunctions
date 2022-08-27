#include "script_component.hpp"
#define TEST __FILE__

private _testFails = [];
LOG_TEST_START;

private _s = ["tests\SFMLParser\multilines2.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);

if ((_s get ERRORS_NODE) NEQ []) exitWith {
    ERROR_ "There are parsing errors detected!" _EOL;
    LOG_TEST_FAILED;
    false;
};

private _newline = "This is a text of newlines.
Each lines is a separate line.

Empty lines are also a new line.
   extra spaicing is saved.";
private _folded = "This is a single line. Merged by one space symbol.  Empty lines are just empty palce.     extra spacing is saved.";

private _sectionPassed = true
&& assert ((_s get "Section" get "Newline") EQ _newline)
&& assert ((_s get "Section"  get "Folded") EQ _folded)
&& assert ([] call (_s get "Section" get "Code") EQ 2);

if (isNil "_sectionPassed" || !_sectionPassed) then {
    ERROR_ "Nested in OBJECT test failed!" _EOL;
    _testFails pushBack false;
};

private _arrayPassed = true
&& assert ((_s get "Array") # 0 EQ _newline)
&& assert ((_s get "Array") # 1 EQ _folded)
&& assert ([] call ((_s get "Array") # 2) EQ 2);

if (isNil "_arrayPassed" || !_arrayPassed) then {
    ERROR_ "Nested in ARRAY test failed!" _EOL;
    _testFails pushBack false;
};

if (_testFails NEQ []) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
