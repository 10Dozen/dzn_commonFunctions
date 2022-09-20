#include "..\test.hpp"

#define COMPONENT SFMLParser

#define LOG_PARSING_ERRORS(MAP) (MAP get "#ERRORS") apply { diag_log text str _x }
#define FAIL_IF_PARSING_ERRORS(MAP) \
    if ((MAP get "#ERRORS") NEQ []) exitWith { \
        ERROR_ "There are parsing errors detected!" _EOL; \
        LOG_TEST_FAILED; \
        false \
    }
