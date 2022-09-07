#include "script_component.hpp"
#define TEST test_comments

LOG_TEST_START;
INIT_FAILED_STEPS_COUNTER;

private _s = ["tests\SFMLParser\comments.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);
_currentFails = 0;

// Hash # escapings
_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "Str", "String", "String with comment");
    ASSERT_EQUALS_EXP(_s get "StrEscaped", "String # with hash", "String with hash");
    ASSERT_EQUALS_EXP(_s get "StrNotEscaped", "String /", "String cut by comment");
    ASSERT_EQUALS_EXP(_s get "QStr", "String # with hash", "Quoted escaping string");
    ASSERT_EQUALS_EXP(_s get "DQStr", "String # with hash", "Double quoted escaping");
    ASSERT_EQUALS_EXP(_s get "Code", { [ARR_3(0,1,2)] # 2 }, "Code with hash selector");
    ASSERT_EQUALS_EXP(_s get "Code2", { '\#' + '3' }, "Code with quoted hash");
    ASSERT_EQUALS_EXP(_s get "Exp", [ARR_3(4,5,6)] # 2, "Expression with hash selector");
    ASSERT_EQUALS_EXP(_s get "MultilineInline", "Some multiline # \\() without comment", "Multiline with hash");
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Escaping HASH (#) tests failed!" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escaping HASH (#) tests passed!" _EOL;
};

// Reference * escapings
_currentFails = _fails;
_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "StrRef", "*Str", "Reference escaping");
    ASSERT_EQUALS_EXP(_s get "StrRefQ", "*Str", "Quoted reference");
    ASSERT_EQUALS_EXP(_s get "StrRefDQ", "*Str", "Double quoted reference");
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Escpaing Reference (*) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Reference (*) tests passed!" _EOL;
};

// Variable <> escapings
_currentFails = _fails;
_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "StrVar", "<Str>", "Variable escaping");
    ASSERT_EQUALS_EXP(_s get "StrVarQ", "<Str>", "Double quoted variable");
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Escpaing Variable (<...>) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Variable (<...>) tests passed!" _EOL;
};

// Array [] escapings
_currentFails = _fails;
_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "StrArr", "[Str]", "Array escaping");
    ASSERT_EQUALS_EXP(_s get "StrArrQ", "[Str]", "Double quoted array");
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Escpaing Array ([...]) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Array ([...]) tests passed!" _EOL;
};

// HashMap () escapings
_currentFails = _fails;
_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "StrMap", "(Str)", "Map escaping");
    ASSERT_EQUALS_EXP(_s get "StrMapQ", "(Str)", "Double quoted map");
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Escpaing Map ((...)) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Map ((...)) tests passed!" _EOL;
};

// Code {} escapings
_currentFails = _fails;
_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "StrCode", "{ code }", "Code escaping");
    ASSERT_EQUALS_EXP(_s get "StrCodeQ", "{ code }", "Double quoted code");
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Escpaing Code ({...}) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Code ({...}) tests passed!" _EOL;
};

// Expression `` escapings
_currentFails = _fails;
_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "StrExp", "`Str`", "Expression escaping");
    ASSERT_EQUALS_EXP(_s get "StrExpQ", "`Str`", "Double quoted expression");
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Escpaing Expression (`...`) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Expression (`...`) tests passed!" _EOL;
};

// Multiline |>^ escapings
private _multilinePassed = true
&& assert ((_s get "StrMultiNewline") EQ "|")
&& assert ((_s get "StrMultiNewlineQ") EQ "|")
&& assert ((_s get "StrMultiFolded") EQ ">")
&& assert ((_s get "StrMultiFoldedQ") EQ ">")
&& assert ((_s get "StrMultiCode") EQ "^")
&& assert ((_s get "StrMultiCodeQ") EQ "^");


_currentFails = _fails;
_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "StrMultiNewline", "|", "Multiline escaping");
    ASSERT_EQUALS_EXP(_s get "StrMultiNewlineQ", "|", "Double quoted multiline");
    ASSERT_EQUALS_EXP(_s get "StrMultiFolded", ">", "Multiline folded escaping");
    ASSERT_EQUALS_EXP(_s get "StrMultiFoldedQ", ">", "Double quoted multiline folded");
    ASSERT_EQUALS_EXP(_s get "StrMultiCode", "^", "Multiline code escaping");
    ASSERT_EQUALS_EXP(_s get "StrMultiCodeQ", "^", "Double quoted multiline code");
_VALIDATION_END_

if (_fails - _currentFails > 0) then {
    ERROR_ "Escpaing Multiline (|,>,^) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Multiline (|,>,^) tests passed!" _EOL;
};

// End
if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
