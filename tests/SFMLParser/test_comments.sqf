#include "script_component.hpp"
#define TEST test_comments

LOG_TEST_START;
INIT_FAILED_STEPS_COUNTER;

private _s = ["tests\SFMLParser\comments.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

TEST_MAP = _s;

// Hash # escapings
private _hashPassed = true
&& assert ((_s get "Str") EQ "String")
&& assert ((_s get "StrEscaped") EQ "String # with hash")
&& assert ((_s get "StrNotEscaped") EQ "String /")
&& assert ((_s get "QStr") EQ "String # with hash")
&& assert ((_s get "DQStr") EQ "String # with hash")
&& assert ((_s get "Code") EQ { [0,1,2] # 2 })
&& assert ((_s get "Code2") EQ { '\#' + '3' })
&& assert ((_s get "Exp") EQ  ([4,5,6] # 2))
&& assert ((_s get "MultilineInline" EQ "Some multiline # \\() without comment"));


if (isNil "_hashPassed" || !_hashPassed) then {
    ERROR_ "Escaping HASH (#) tests failed!" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escaping HASH (#) tests passed!" _EOL;
};

// Reference * escapings
private _refPassed = true
&& assert ((_s get "StrRef") EQ "*Str")
&& assert ((_s get "StrRefQ") EQ "*Str")
&& assert ((_s get "StrRefDQ") EQ "*Str");

if (isNil "_refPassed" || !_refPassed) then {
    ERROR_ "Escpaing Reference (*) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Reference (*) tests passed!" _EOL;
};

// Variable <> escapings
private _varPassed = true
&& assert ((_s get "StrVar") EQ "<Str>")
&& assert ((_s get "StrVarQ") EQ "<Str>");

if (isNil "_varPassed" || !_varPassed) then {
    ERROR_ "Escpaing Variable (<...>) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Variable (<...>) tests passed!" _EOL;
};

// Array [] escapings
private _arrPassed = true
&& assert ((_s get "StrArr") EQ "[Str]")
&& assert ((_s get "StrArrQ") EQ "[Str]");

if (isNil "_arrPassed" || !_arrPassed) then {
    ERROR_ "Escpaing Array ([...]) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Array ([...]) tests passed!" _EOL;
};

// HashMap () escapings
private _mapPassed = true
&& assert ((_s get "StrMap") EQ "(Str)")
&& assert ((_s get "StrMapQ") EQ "(Str)");

if (isNil "_mapPassed" || !_mapPassed) then {
    ERROR_ "Escpaing Map ((...)) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Map ((...)) tests passed!" _EOL;
};

// Code {} escapings
private _codePassed = true
&& assert ((_s get "StrCode") EQ "{ code }")
&& assert ((_s get "StrCodeQ") EQ "{ code }");

if (isNil "_codePassed" || !_codePassed) then {
    ERROR_ "Escpaing Code ({...}) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Code ({...}) tests passed!" _EOL;
};

// Expression `` escapings
private _expPassed = true
&& assert ((_s get "StrExp") EQ "`Str`")
&& assert ((_s get "StrExpQ") EQ "`Str`");

if (isNil "_expPassed" || !_expPassed) then {
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

if (isNil "_multilinePassed" || !_multilinePassed) then {
    ERROR_ "Escpaing Multiline (|,>,^) tests failed" _EOL;
    FAIL_STEP;
} else {
    INFO_ "Escpaing Multiline (|,>,^) tests passed!" _EOL;
};

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
