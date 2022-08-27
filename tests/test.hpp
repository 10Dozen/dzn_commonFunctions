
#define EQ isEqualTo
#define NEQ isNotEqualTo

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
    diag_log text '[COMPONENT] ---------------------------------------------'

#define LOG_ diag_log text ('[COMPONENT.TEST] ' + format [
#define INFO_ diag_log text ('[COMPONENT.TEST] (info) ' + format [
#define ERROR_ diag_log text ('[COMPONENT.TEST] (error) ' + format [
#define _EOL ])

#define INIT_STEP_FAILS_COUNTER private _fails = 0
#define FAIL_STEP _fails = _fails + 1
#define FAILED_STEPS_EXISTS _fails > 0
