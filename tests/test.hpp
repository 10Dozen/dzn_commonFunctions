#define QUOTE(X) #X


#define LOG_TEST_START diag_log text '[COMPONENT.TEST] Started'
#define LOG_TEST_PASSED diag_log text '[COMPONENT.TEST]           OK!'
#define LOG_TEST_FAILED diag_log text '[COMPONENT.TEST]           FAILED!'

#define RUN_SUITE \
    diag_log text '[COMPONENT] ---------------------------------------------'; \
    diag_log text format ['[COMPONENT] Suite Started (%1 test(s))', count _tests]; \
    diag_log text '[COMPONENT] ---------------------------------------------'; \
    private _results = [];\
    {\
        private _r = call compile preprocessFileLineNumbers format ["%1\%2.sqf", _path, _x]; \
        _results pushback _r; \
    } forEach _tests; \
    diag_log text '[COMPONENT] ---------------------------------------------'; \
    diag_log text format ['[COMPONENT] RESULT: %1', ["PASSED", "FAILED"] select (false in _results)]; \
    diag_log text format ['[COMPONENT]   Passed: %1', {_x} count _results]; \
    diag_log text format ['[COMPONENT]   Failed: %1', {!_x} count _results]; \
    diag_log text '[COMPONENT] ---------------------------------------------'; \
    if (false in _results) then {\
        diag_log text '[COMPONENT] Failed tests:';\
        { if (!_x) then { diag_log text format ['[COMPONENT]   %1', _tests select _forEachIndex]; }; } forEach _results;\
        diag_log text '[COMPONENT] ---------------------------------------------'; \
    };\
    ["PASSED", "FAILED"] select (false in _results)

#define LOG_ diag_log text ('[COMPONENT.TEST] ' + format [
#define INFO_ diag_log text ('[COMPONENT.TEST] (info) ' + format [
#define ERROR_ diag_log text ('[COMPONENT.TEST] (error) ' + format [
#define _EOL ])

#define INIT_FAILED_STEPS_COUNTER private _fails = 0
#define FAIL_STEP _fails = _fails + 1
#define FAILED_STEPS_EXISTS _fails > 0

#define _VALIDATION_ while {
#define _VALIDATION_END_ false } do {};

#define EQ isEqualTo
#define NEQ isNotEqualTo

#define ASSERT_NIL(VAR) \
    if (!isNil QUOTE(VAR)) exitWith { \
        FAIL_STEP; \
        ERROR_ "Variable %1 is not nil!", QUOTE(VAR) _EOL; \
    }

#define ASSERT_NOT_NIL(VAR) \
    if (isNil QUOTE(VAR)) exitWith { \
        FAIL_STEP; \
        ERROR_ "Variable %1 is nil!", QUOTE(VAR) _EOL; \
    }

#define ASSERT_TRUE(COND,MSG) \
    if !(COND) exitWith { \
        FAIL_STEP; \
        ERROR_ MSG _EOL; \
    }

#define ASSERT_FALSE(COND,MSG) \
    if (COND) exitWith { \
        FAIL_STEP; \
        ERROR_ MSG _EOL; \
    }

#define ASSERT_EQUALS(VAR1,VAR2) \
    if (!(VAR1 isEqualType VAR2) || {VAR1 isNotEqualTo VAR2}) exitWith {\
        FAIL_STEP; \
        ERROR_ "Variable [%1] expected to be [%2], but actual [%3]", QUOTE(VAR1), VAR1, VAR2 _EOL; \
    }

#define ASSERT_EQUALS_EXP(EXP1,VAR2,TAG) \
    if (isNil {EXP1}) exitWith { \
        FAIL_STEP; \
        ERROR_ "Assert equals failed [tag: %1] - expression resulted in NIL! Expected [%2]", TAG, VAR2 _EOL; \
    }; \
    if (!((EXP1) isEqualType VAR2) || {(EXP1) isNotEqualTo VAR2}) exitWith {\
        FAIL_STEP;\
        ERROR_ "Assert equals failed [tag: %1]. Expected [%2], but actual [%3]", TAG, VAR2, EXP1 _EOL;\
    }

// Utils
#define ARR_1(ARG1) ARG1
#define ARR_2(ARG1,ARG2) ARG1, ARG2
#define ARR_3(ARG1,ARG2,ARG3) ARG1, ARG2, ARG3
#define ARR_4(ARG1,ARG2,ARG3,ARG4) ARG1, ARG2, ARG3, ARG4
#define ARR_5(ARG1,ARG2,ARG3,ARG4,ARG5) ARG1, ARG2, ARG3, ARG4, ARG5
#define ARR_6(ARG1,ARG2,ARG3,ARG4,ARG5,ARG6) ARG1, ARG2, ARG3, ARG4, ARG5, ARG6
#define ARR_7(ARG1,ARG2,ARG3,ARG4,ARG5,ARG6,ARG7) ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7
#define ARR_8(ARG1,ARG2,ARG3,ARG4,ARG5,ARG6,ARG7,ARG8) ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8