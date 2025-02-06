
#define COB dzn_SFML

// Some tackles
#define Q(X) #X

#define COMPILE_SCRIPT(NAME) compileScript [format ["dzn_commonFunctions\functions\common\SFML\%1.sqf", Q(NAME)]]
#define PREP_COB_FUNCTION(NAME) [Q(NAME), compileScript [format ["dzn_commonFunctions\functions\common\SFML\fnc_%1.sqf", Q(NAME)]]]
#define F(NAME) Q(NAME)

//#define DEBUG DEBUG
#define LOG_PREFIX '[dzn_fnc_parseSFML] PARSER: '
#define LOG_1(MSG) diag_log text format [LOG_PREFIX + MSG,ARG1]
#define LOG_2(MSG,ARG1,ARG2) diag_log text format [LOG_PREFIX + MSG,ARG1,ARG2]
#define LOG_3(MSG,ARG1,ARG2,ARG3) diag_log text format [LOG_PREFIX + MSG,ARG1,ARG2,ARG3]

#ifdef DEBUG
    #define DBG_PREFIX '[dzn_fnc_parseSFML] PARSER:DEBUG> '
    #define DBG(MSG) diag_log text (DBG_PREFIX + MSG)
    #define DBG_1(MSG,ARG1) diag_log text format [DBG_PREFIX + MSG,ARG1]
    #define DBG_2(MSG,ARG1,ARG2) diag_log text format [DBG_PREFIX + MSG,ARG1,ARG2]
    #define DBG_3(MSG,ARG1,ARG2,ARG3) diag_log text format [DBG_PREFIX + MSG,ARG1,ARG2,ARG3]
    #define DBG_4(MSG,ARG1,ARG2,ARG3,ARG4) diag_log text format [DBG_PREFIX + MSG,ARG1,ARG2,ARG3,ARG4]
#else
    #define DBG_PREFIX
    #define DBG(MSG)
    #define DBG_1(MSG,ARG1)
    #define DBG_2(MSG,ARG1,ARG2)
    #define DBG_3(MSG,ARG1,ARG2,ARG3)
    #define DBG_4(MSG,ARG1,ARG2,ARG3,ARG4)
#endif

// Parser mode
#define MODE_ROOT 0
#define MODE_NESTED 10
#define MODE_NESTED_ARRAY 11
#define MODE_NESTED_OBJECT 12
#define MODE_MULTILINE_TEXT 20

// Multiline settings
#define MULTILINE_MODE_NEWLINES 300
#define MULTILINE_MODE_FOLDED 310
#define MULTILINE_MODE_CODE 320

#define ONELINER_ARRAY 1000
#define ONELINER_HASHMAP 1001

#define EOF "#EOF"

#define CURRENT_NODE_KEY (if (count _hashNodesRoute > 0) then {_hashNodesRoute select (count _hashNodesRoute - 1)} else {""})
#define STRIP(X) (X select [1, count X - 2])
#define IS_REF_VALUE(X) (X select [0, REF_PREFIX_PROCESSED_LENGTH] == REF_PREFIX_PROCESSED)
#define IS_MULTILINE_START(X) ((toArray X select 0) in [MULTILINE_NEWLINES_PREFIX, MULTILINE_FOLDED_PREFIX, MULTILINE_CODE_PREFIX])
#define IS_IN_ARRAY_NODE (typename CURRENT_NODE_KEY == "SCALAR")

// Error reporting
#define REPORT_ERROR_NOLINE(ERROR_CODE, MSG) (_hash get ERRORS_NODE) pushBack [ERROR_CODE, -1, '', MSG];
#define REPORT_ERROR_NOLINE_1(ERROR_CODE, MSG, ARG1) (_hash get ERRORS_NODE) pushBack [ERROR_CODE, -1, '', MSG, ARG1];
#define REPORT_ERROR_NOLINE_2(ERROR_CODE, MSG, ARG1, ARG2) (_hash get ERRORS_NODE) pushBack [ERROR_CODE, -1, '', MSG, ARG1, ARG2];

#define FORMAT_LINE_INFO(LINE_NO, MSG) format ["Line %1: %2", LINE_NO, MSG]
#define REPORT_ERROR(ERROR_CODE, LINE_NO, MSG) (_hash get ERRORS_NODE) pushBack [ERROR_CODE,LINE_NO+1,FORMAT_LINE_INFO(LINE_NO+1,_lines select LINE_NO),MSG]
#define REPORT_ERROR_1(ERROR_CODE, LINE_NO, MSG, ARG1) (_hash get ERRORS_NODE) pushBack [ERROR_CODE,LINE_NO+1,FORMAT_LINE_INFO(LINE_NO+1,_lines select LINE_NO),MSG,ARG1]
#define REPORT_ERROR_2(ERROR_CODE, LINE_NO, MSG, ARG1, ARG2) (_hash get ERRORS_NODE) pushBack [ERROR_CODE,LINE_NO+1,FORMAT_LINE_INFO(LINE_NO+1,_lines select LINE_NO),MSG,ARG2]


#include "SFMLParser.hpp"