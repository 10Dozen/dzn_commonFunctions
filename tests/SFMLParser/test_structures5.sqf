#include "script_component.hpp"
#define TEST test_structures5

INIT_FAILED_STEPS_COUNTER;
LOG_TEST_START;

private _s = ["tests\SFMLParser\structures5.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

// TEST_MAP = _s;

_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "Foo", "Bar", "Ending key");

    private _arr = _s get "RootSection" get "NestedArray";
    ASSERT_NOT_NIL(_arr);
    ASSERT_EQUALS((count _arr), 2);

    ASSERT_EQUALS_EXP((_arr # 0) get "game", "Guilty Gear", "Section\Array\0\Hash.key");
    private _gameChars = (_arr # 0) get "chars";
    ASSERT_NOT_NIL(_gameChars);
    ASSERT_EQUALS(count _gameChars, 2);

    ASSERT_EQUALS_EXP((_gameChars # 0) get "name", "Kuradoberi Jam", "Section\Array\0\Hash.Array\0\Key1");
    ASSERT_EQUALS_EXP((_gameChars # 0) get "origin", "China", "Section\Array\0\Hash.Array\0\Key2");
    ASSERT_EQUALS_EXP((_gameChars # 0) get "details" get "gender", "F", "Section\Array\0\Hash.Array\0\Section\Key1");
    ASSERT_EQUALS_EXP((_gameChars # 0) get "details" get "height", 163, "Section\Array\0\Hash.Array\0\Section\key2");
    ASSERT_EQUALS_EXP((_gameChars # 0) get "details" get "weight", 48, "Section\Array\0\Hash.Array\0\Section\Key3");
    ASSERT_EQUALS_EXP((_gameChars # 0) get "participated", [ARR_4("GG","GGX","GGXRd","GG Strive")], "Section\Array\0\Hash.Array\0\Hash.Array");

    ASSERT_EQUALS_EXP((_gameChars # 1) get "name", "Ky Kiske", "Section\Array\0\Hash.Array\1\Key1");
    ASSERT_EQUALS_EXP((_gameChars # 1) get "origin", "France", "Section\Array\0\Hash.Array\1\Key2");
    ASSERT_EQUALS_EXP((_gameChars # 1) get "details" get "gender", "M", "Section\Array\0\Hash.Array\1\Section\Key1");
    ASSERT_EQUALS_EXP((_gameChars # 1) get "details" get "height", 178, "Section\Array\0\Hash.Array\1\Section\key2");
    ASSERT_EQUALS_EXP((_gameChars # 1) get "details" get "weight", 58, "Section\Array\0\Hash.Array\1\Section\Key3");
    ASSERT_EQUALS_EXP((_gameChars # 1) get "participated", [ARR_5("GG","GGX","GG2","GGXRd","GG Strive")], "Section\Array\0\Hash.Array\1\Hash.Array");

    ASSERT_EQUALS_EXP((_arr # 1) get "game", "King of Fighters", "Section\Array\1\Hash.key");
    _gameChars = (_arr # 1) get "chars";
    ASSERT_NOT_NIL(_gameChars);
    ASSERT_EQUALS(count _gameChars, 2);

    ASSERT_EQUALS_EXP((_gameChars # 0) get "name", "Athena", "Section\Array\1\Hash.Array\0\Key1");
    ASSERT_EQUALS_EXP((_gameChars # 0) get "origin", "Japan", "Section\Array\1\Hash.Array\0\Key2");
    ASSERT_EQUALS_EXP((_gameChars # 0) get "details" get "gender", "F", "Section\Array\1\Hash.Array\0\Section\Key1");
    ASSERT_EQUALS_EXP((_gameChars # 0) get "details" get "height", 162, "Section\Array\1\Hash.Array\0\Section\key2");
    ASSERT_EQUALS_EXP((_gameChars # 0) get "details" get "weight", 49, "Section\Array\1\Hash.Array\0\Section\Key3");
    ASSERT_EQUALS_EXP((_gameChars # 0) get "participated", [ARR_2("KOF'95","KOF'97")], "Section\Array\1\Hash.Array\0\Hash.Array");

    ASSERT_EQUALS_EXP((_gameChars # 1) get "name", "Iori", "Section\Array\1\Hash.Array\1\Key1");
    ASSERT_EQUALS_EXP((_gameChars # 1) get "origin", "Japan", "Section\Array\1\Hash.Array\1\Key2");
    ASSERT_EQUALS_EXP((_gameChars # 1) get "details" get "gender", "M", "Section\Array\1\Hash.Array\1\Section\Key1");
    ASSERT_EQUALS_EXP((_gameChars # 1) get "details" get "height", 182, "Section\Array\1\Hash.Array\1\Section\key2");
    ASSERT_EQUALS_EXP((_gameChars # 1) get "details" get "weight", 79, "Section\Array\1\Hash.Array\1\Section\Key3");
    ASSERT_EQUALS_EXP((_gameChars # 1) get "participated", [ARR_3("KOF'95","KOF'96","KOF'97")], "Section\Array\0\Hash.Array\1\Hash.Array");

_VALIDATION_END_

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
ASSERT_EQUALS_EXP
