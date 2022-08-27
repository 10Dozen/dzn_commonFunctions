#include "..\test.hpp"
#include "..\..\dzn_commonFunctions\functions\common\SFMLParser.hpp"

#define COMPONENT SFMLParser

#define LOG_PARSING_ERRORS(MAP) (MAP get ERRORS_NODE) apply { diag_log text str _x }
#define FAIL_IF_PARSING_ERRORS(MAP) \
    if ((MAP get ERRORS_NODE) NEQ []) exitWith { \
        ERROR_ "There are parsing errors detected!" _EOL; \
        LOG_TEST_FAILED; \
        false \
    }
