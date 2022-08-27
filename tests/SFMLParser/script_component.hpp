#include "..\test.hpp"
#include "..\..\dzn_commonFunctions\functions\common\SFMLParser.hpp"

#define COMPONENT SFMLParser

#define LOG_PARSING_ERRORS(MAP) (MAP get ERRORS_NODE) apply { diag_log text str _x }
