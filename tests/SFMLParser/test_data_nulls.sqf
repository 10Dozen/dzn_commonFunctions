#include "script_component.hpp"
#define TEST test_data_nulls

LOG_TEST_START;

private _s = ["tests\SFMLParser\data_sides.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

private _passed = true
    && assert ((_s get "objNull") EQ objNull)
    && assert ((_s get "grpNull") EQ grpNull)
    && assert ((_s get "locationNull") EQ locationNull)
    && assert ((_s get "controlNull") EQ controlNull)
    && assert ((_s get "displayNull") EQ displayNull)
    && assert ((_s get "taskNull") EQ taskNull)
    && assert ((_s get "scriptNull") EQ scriptNull)
    && assert ((_s get "configNull") EQ configNull)
    && assert ((_s get "diaryRecordNull") EQ diaryRecordNull)
    && assert ((_s get "teamMemberNull") EQ teamMemberNull);


if (!_passed) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
