#include "script_component.hpp"
#define TEST test_data_nulls

LOG_TEST_START;
INIT_FAILED_STEPS_COUNTER;

private _s = ["tests\SFMLParser\data_nulls.yml"] call dzn_fnc_parseSFML;
LOG_PARSING_ERRORS(_s);
FAIL_IF_PARSING_ERRORS(_s);

_VALIDATION_
    ASSERT_EQUALS_EXP(_s get "objNull", objNull, "objNull type");
    ASSERT_EQUALS_EXP(_s get "grpNull", grpNull, "grpNull type");
    ASSERT_EQUALS_EXP(_s get "locationNull", locationNull, "locationNull type");
    ASSERT_EQUALS_EXP(_s get "controlNull", controlNull, "controlNull type");
    ASSERT_EQUALS_EXP(_s get "displayNull", displayNull, "displayNull type");
    ASSERT_EQUALS_EXP(_s get "taskNull", taskNull, "taskNull type");
    ASSERT_EQUALS_EXP(_s get "scriptNull", scriptNull, "scriptNull type");
    ASSERT_EQUALS_EXP(_s get "configNull", configNull, "configNull type");
    ASSERT_EQUALS_EXP(_s get "diaryRecordNull", diaryRecordNull, "diaryRecordNull type");
    ASSERT_EQUALS_EXP(_s get "teamMemberNull", teamMemberNull, "teamMemberNull type");
_VALIDATION_END_

if (FAILED_STEPS_EXISTS) exitWith {
    LOG_TEST_FAILED;
    false
};

LOG_TEST_PASSED;
true
