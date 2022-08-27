#include "script_component.hpp"
#define TEST test_structure_arrays2

LOG_TEST_START;

test_var = 123;

private _s = ["tests\SFMLParser\structure_arrays2.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);

private _plain = _s get "PlainDataTypes";
private _oneliner = _s get "OnelinerDataTypes";

if ((_s get ERRORS_NODE) isNotEqualTo []
    || isNil "_plain"
    || isNil "_oneliner"
) exitWith {
    ERROR_ "There are parsing errors detected!" _EOL;
    LOG_TEST_FAILED;
    false
};

private _mapToCheck = createHashMapFromArray [["name","John"],["age", 32]];
private _passed = true;
{
    _x params [
        "_string",
        "_qstring",
        "_num",
        "_numEq",
        "_eval",
        "_bool",
        "_code",
        "_varExp",
        "_varImp",
        "_side",
        "_hash",
        "_arr",
        "_nil",
        "_null"
    ];

    INFO_ "Checking %1", _x _EOL;

    _passed = _passed
    && assert (_string EQ "String")
    && assert (_qstring EQ "String")
    && assert (_num EQ 123)
    && assert (_numEq EQ (23 + 23))
    && assert (_eval EQ (12 min 3))
    && assert (_bool)
    && assert (_code EQ { hint "Code!"; })
    && assert (_varExp EQ test_var)
    && assert (_varImp EQ test_var)
    && assert (_side EQ blufor)
    && assert (_hash EQ _mapToCheck)
    && assert (_arr EQ [1,2,3])
    && assert (isNil "_nil" && count _x == 14)
    && assert (_null EQ objNull);

} forEach [_plain, _oneliner];

test_var = nil;

if (isNil "_passed" || { !_passed }) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
