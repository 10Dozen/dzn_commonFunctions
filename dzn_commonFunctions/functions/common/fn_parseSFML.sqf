/*
 * @Hash = [@Input, @Mode, @Args] call dzn_fnc_parseSFML
 * Parses YAML-like settinsg file to HashMap.
 *
 * INPUT:
 * 0: STRING - path to file to parse (for LOAD_FILE and PREPROCESS_FILE modes) OR comma-separated oneliner with properties to parse (PARSE_LINE mode).
 * 1: STRING - mode to apply (optional):
 *              1) "LOAD_FILE" -- tries to load file from path given in @Input and parse it. Default mode.
 *              2) "PREPROCESS_FILE" -- tries to load & preprocess file from given path (using Arma 3 preprocessor) and parse.
 *              3) "PARSE_LINE" -- parse given Input string.
 * 2: ANY - arguments to pass into parsing scope. Will be available as _this during expression data types parsing (e.g. key: `_this`).
 *
 * OUTPUT:
 * HASHMAP - map of the parsed settings. Each section will be available under it's key.
 *               Special keys:
 *
 *              a) '#SOURCE' key - string with path to parsed file or input (same as function argument).
 *
 *              b) '#ERRORS' key - array of parsing errors in format:
 *              [_errorCode, _lineNo, _lineContent, _reason, (optional) _param1, ... , _paramN].
 *              where:
 *              _errorCode - (number) error code from \dzn_commonFunctions\functions\common\SFMLParser.hpp
 *              _lineNo - (number) line number (approximate)
 *              _lineContent - (string) content of the parsed line
 *              _reason - (string) human readable reason of the error
 *              _param1..n - (any) additional parameter of the error. Optional.
 *
 * EXAMPLES:
 *      _settings = ["dzn_tSFramework\Modules\Chatter\Settings.yaml"] call dzn_fnc_parseSFML;
 *      // (_settings get "key")
 *
 *      _props = ["myStr: Some text, myNum: 22", "PARSE_LINE"] call dzn_fnc_parseSFML;
 *      // (_props get "myNum") = 22
 *      // (_props get "myStr") = "Some text"
 */

#include "SFMLParser.hpp"

// #define DEBUG DEBUG

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

params ["_input", ["_dataMode", MODE_FILE_LOAD], ["_args", []]];

DBG_1("Params: %1", _this);
DBG_1("Mode: %1", _dataMode);

private _startAt = diag_tickTime;
private _printStatistics = true;

private _hash = createHashMap;
_hash set [SOURCE_NODE, _input];
_hash set [ERRORS_NODE, []];

_dataMode = toUpper _dataMode;
private _data = switch _dataMode do {
    case MODE_FILE_LOAD: { loadFile _input };
    case MODE_FILE_PREPROCESS: { preprocessFile _input };
    case MODE_PARSE_LINE: {
        _printStatistics = false;
        if ([_input] call CBA_fnc_trim == "") then {
            ""
        } else {
            format ["%1: (%2)", DATA_NODE, _input]
        }
    };
    default {
        DBG_1("[ERROR:ERR_MODE_UNDEFINED] Data mode [%1] is unknown!", _dataMode);
        REPORT_ERROR_NOLINE_1(ERR_MODE_UNDEFINED, "Data mode [%1] is unknown!", _dataMode);
        ""
    };
};

DBG_1("Data: %1 chars", count _data);

if (count _data == 0) exitWith {
    // diag_log text format ["[dzn_fnc_parseSettingsFile] Warning! Input [%1] is empty!", _input];
    REPORT_ERROR_NOLINE(ERR_FILE_EMPTY, 'File is empty!');
    _hash
};

forceUnicode 1;

// --- Functions
private _fnc_splitLines = {
    // Splits input data into array of lines. It also removes comments if present.
    params ["_data"];

    private _chars = toArray _data;
    private _isRawFile = _dataMode == MODE_FILE_LOAD;
    private _linebreak = [[ASCII_NL], [ASCII_CR, ASCII_NL]] select (ASCII_CR in _chars);
    private _linebreakSize = count _linebreak;
    _chars append _linebreak;
    private _lineChars = [];
    private _lines = [];
    DBG_1("(splitLines) Linebreaks size: %1", _linebreakSize);

    for "_i" from 0 to (count _chars - _linebreakSize) do {
        private _char = _chars # _i;
        private _normalizedLine = "";
        switch _char do {
            case ASCII_CR: {
                if ([_char, _chars # (_i + 1)] isEqualTo _linebreak) then {
                    DBG_1("(splitLines) EOL (ASCII_CR, ASCII_NL) detected at position %1", _i);
                    _normalizedLine = toString ([_lineChars] call _fnc_removeComment);
                    _lines pushBack _normalizedLine;
                    _lineChars resize 0;
                    // Skip next char as it expected to be ASCII_NL from [ASCII_CR, ASCII_NL] end of line pair
                    _i = _i + 1;
                } else {
                    // _lineChars pushBack _char;
                };
            };
            case ASCII_NL: {
                DBG_1("(splitLines) EOL (ASCII_NL) detected at position %1", _i);
                // Comments are handled differently in LOAD_FILE and PREPROCESS_FILE modes
                _normalizedLine = toString(if (_isRawFile) then {
                    [_lineChars] call _fnc_removeComment
                } else {
                    _lineChars
                });
                _lines pushBack _normalizedLine;
                _lineChars resize 0;
            };
            case ASCII_VERTICAL_LINE: {
                if (_lineChars isEqualTo [] && !_isRawFile) then {
                    // | in the beginning of the line & file is preprocessed - escape it
                    continue;
                } else {
                    _lineChars pushBack _char;
                };
            };
            default {
                _lineChars pushBack _char;
            }
        };

        if (_normalizedLine isNotEqualTo "") then {
            DBG_1("(splitLines) Line found and normalized: %1", _normalizedLine);
        };
    };

    _lines pushBack EOF;

    _lines
};

private _fnc_removeComment = {
    // Removes comments (text after # char) from the line.
    // Do nothing if # char is shadowed by \ or / symbol
    params ["_chars"];

    if !(ASCII_HASH in _chars) exitWith { _chars };

    private _size = count _chars;
    private _commentStartedIndex = -1;
    private _escapedHashes = [];
    private _inQuotes = false;
    private _openQuoteChar = -1;
    private _inCode = false;
    private _inCodeDepth = 0;
    private ["_char"];

    DBG_1("(removeComment) Line: %1", toString _chars);

    for "_j" from 0 to _size-1 do {
        _char = _chars # _j;

        switch _char do {
            case ASCII_HASH: {
                if (_inQuotes || _inCode) exitWith {
                    DBG_1("(removeComment) Found nested hash at %1. Ignored.", _j);
                }; // Ignore hashes inside the quotes or code
                if (_j == 0) exitWith {
                    _commentStartedIndex = _j;
                    DBG_1("(removeComment) Found hash at %1", _j);
                };
                if (_chars # (_j - 1) == ASCII_BACKSLASH) then {
                    _escapedHashes pushBack _j - 1;
                    DBG_1("(removeComment) Found escaped hash at : %1", _j - 1);
                } else {
                    _commentStartedIndex = _j;
                    DBG_1("(removeComment) Found hash at %1", _j);
                };
            };
            case ASCII_GRAVE;
            case ASCII_QUOTE;
            case ASCII_DOUBLE_QUOTE: {
                if (_inCode) exitWith {}; // Strings in code
                if (!_inQuotes) exitWith {
                    _openQuoteChar = _char;
                    _inQuotes = true;
                };
                if (_inQuotes && _char == _openQuoteChar) exitWith {
                    _openQuoteChar = -1;
                    _inQuotes = false;
                };
            };
            case ASCII_CURLY_BRACKET_OPEN: {
                if (_inQuotes) exitWith {};
                _inCode = true;
                _inCodeDepth = _inCodeDepth + 1;
            };
            case ASCII_CURLY_BRACKET_CLOSE: {
                if (_inQuotes || !_inCode) exitWith {};
                _inCodeDepth = _inCodeDepth - 1;
                // Close inCode mode
                if (_inCodeDepth == 0) exitWith {
                    _inCode = false;
                };
            };
        };

        if (_commentStartedIndex > -1) exitWith {};
    };

    // Clear comments
    if (_commentStartedIndex > -1) then {
        _chars deleteRange [_commentStartedIndex, _size];
    };

    // Unwrap escaped hashes: \# -> #
    reverse _escapedHashes;
    { _chars deleteAt _x } forEach _escapedHashes;

    _chars
};

private _fnc_parseKeyValuePair = {
    /* Parses line data into key and value by ":" char.
       Return one of the results:
        [] -- line doesn't contain ":" char
        [_key, ""] -- line contain only key (start of the nested section)
        [_key, _value] -- line is key-value pair
    */
    params ["_line"];
    if !(":" in _line) exitWith {
        DBG("(parseKeyValuePair) -----------# No key definition found, this is not an key-value pair");
        []
    };
    private _parts = _line splitString ":";
    private _key = [_parts # 0] call CBA_fnc_trim;
    _parts deleteAt 0;
    private _value = [_parts joinString ":"] call CBA_fnc_trim;

    DBG_3("(parseKeyValuePair) -----------# #PARSED# Key: %2, Value: %3", _forEachIndex, _key, _value);
    [_key, _value]
};

private _fnc_addArrayItem = {
    // Adds new item to current active array hash node in format [index, value]
    params ["_item"];
    private _node = [] call _fnc_getNode;
    private _key = count keys _node;
    _node set [_key, if (isNil "_item") then { nil } else { _item }];
    DBG_3("(addArrayItem) Adding array node %1 with item [%2]. Nodes: %3", _key, _item, _hashNodesRoute);

    DBG("(addArrayItem) ----------- Add array item to hash node -------------");
    DBG_1("(addArrayItem) %1", values _node);
    DBG("(addArrayItem) ------------------------------------------------------");

    (_key)
};

private _fnc_getNode = {
    // Return current active node
    params [["_nodes", _hashNodesRoute]];

    DBG_1("(getCurrentNode) Nodes: %1", _nodes);

    private _node = _hash;
    { _node = _node get _x; } forEach _nodes;
    _node
};

private _fnc_addNode = {
    // Adds new node and makes it active
    params ["_key"];

    DBG_1("(addNode) Adding node: %1", _key);
    private _node = [] call _fnc_getNode;

    DBG_1("(addNode) Node exists?: %1", !isNil {_node get _key});
    if (!isNil {_node get _key}) then {
        REPORT_ERROR(ERR_NODE_DUPLICATE, _forEachIndex, "Duplicate node found!");
    };
    _node set [_key, createHashMap];
    _hashNodesRoute pushBack _key;
    DBG_1("(addNode) Nodes now: %1", _hashNodesRoute);
};

private _fnc_calculateExpectedIndent = {
    // Returns expected indent, according to current active node position
    DBG_1("(calculateExpectedIndent) Nodes: %1", _hashNodesRoute);
    private _expected = 0;
    {
        if (typename _x == "SCALAR") then {
            private _tline = [_line] call CBA_fnc_trim;
            if (_tline select [0,1] != "-") then {
                _expected = _expected + INDENT_ARRAY_NESTED;
                DBG_2("(calculateExpectedIndent) Node %1: Nested into array (+%2)", _forEachIndex, INDENT_ARRAY_NESTED);
            } else {
                _expected = _expected + INDENT_ARRAY_NESTED;
                DBG_2("(calculateExpectedIndent) Node %1: Array node (+%2)", _forEachIndex, INDENT_ARRAY_NESTED);
            };
        } else {
            _expected = _expected + INDENT_DEFAULT;
            DBG_2("(calculateExpectedIndent) Node %1: Section/nested in section node (+%2)", _forEachIndex, INDENT_DEFAULT);
        };
    } forEach _hashNodesRoute;

    _expected
};

private _fnc_initMultilineBuffer = {
    // Initializes multiline variables and buffer
    params ["_key", "_indent", "_initLine"];
    DBG_1("(fnc_initMultilineBuffer) Params: %1", _this);

    private _mode = switch (toArray _initLine # 0) do {
        case ASCII_VERTICAL_LINE: { MULTILINE_MODE_NEWLINES };
        case ASCII_GT: { MULTILINE_MODE_FOLDED };
        case ASCII_CARET: { MULTILINE_MODE_CODE };
    };

    _hash set [MULTILINE_KEY_NODE, _key];
    _hash set [MULTILINE_VALUE_NODE, []];
    _hash set [MULTILINE_INDENT_NODE, INDENT_MULTILINE + _indent];
    _hash set [MULTILINE_MODE_NODE, _mode];

    DBG_1("(fnc_initMultilineBuffer) Key set to: %1", _hash get MULTILINE_KEY_NODE);
    DBG_1("(fnc_initMultilineBuffer) Indent set to: %1", _hash get MULTILINE_INDENT_NODE);
    DBG_1("(fnc_initMultilineBuffer) Mode set to: %1", _hash get MULTILINE_MODE_NODE);
};

private _fnc_parseOnelinerStructure = {
    /* Converts oneliner Array or HashMap into valid Array/Hashmap datatype
       Params:
       _oneliner - (string) oneliner line.
       _mode - (enum) one of the folowing: ONELINER_ARRAY, ONELINER_HASHMAP (see defines section)
       Return:
       _onelinerConverted - (Array or HashMap) converted oneliner data structure.
    */
    params ["_oneliner", "_mode"];
    DBG_2("(parseOnelinerStructure) Oneliner: %1. Mode: %2", _oneliner, _mode);

    private _chars = toArray STRIP(_oneliner) + [ASCII_COMMA];
    private _lenght = count _chars - 1;
    private _onelinerConverted = [];
    private _item = [];

    private _inQuotes = false;
    private _openQuoteChar = -1;

    private _inBracket = false;
    private _openBracketChar = -1;
    private _inBracketsDepth = 0;
    private _bracketsOpenCloseMap = createHashMapFromArray [
        [ASCII_PARENTHESES_OPEN, ASCII_PARENTHESES_CLOSE],
        [ASCII_CURLY_BRACKET_OPEN, ASCII_CURLY_BRACKET_CLOSE],
        [ASCII_SQUARE_BRACKET_OPEN, ASCII_SQUARE_BRACKET_CLOSE]
    ];

    for "_i" from 0 to _lenght do {
        private _char = _chars # _i;
        switch _char do {
            // Item separator
            case ASCII_COMMA: {
                if (_inQuotes || _inBracket) exitWith {}; // Ignore comma inside quotes/brackets

                private _itemStr = [toString _item] call CBA_fnc_trim;
                DBG_1("(parseOnelinerStructure) Found item: %1", _itemStr);

                switch _mode do {
                    case ONELINER_ARRAY: {
                        DBG_1("(parseOnelinerStructure) Converting %1 to ARRAY item", _itemStr);
                        private _value = [_itemStr] call _fnc_parseValueType;

                        // Make a set, because pushBack ignores 'nil' value (which may be set by user or as result of nil variable reference)
                        _onelinerConverted set [count _onelinerConverted,  if (isNil "_value") then { nil } else { _value }];
                    };
                    case ONELINER_HASHMAP: {
                        DBG_1("(parseOnelinerStructure) Converting %1 to HASHMAP key-value pair", _itemStr);
                        private _parsed = [_itemStr] call _fnc_parseKeyValuePair;
                        DBG_1("(parseOnelinerStructure) Parsed key-value: %1", _parsed);

                        if (_parsed isEqualTo []) exitWith {
                            REPORT_ERROR_1(ERR_DATA_KEYVALUEPAIR_MALFORMED, _forEachIndex, "One-liner HashMap pair is malformed", _itemStr);
                        };

                        _parsed params ["_key", "_value"];
                        _value = [_value] call _fnc_parseValueType;
                        _onelinerConverted pushBack [_key, if (isNil "_value") then { nil } else { _value }];
                    };
                };

                _item resize 0;
                _char = nil;
                continue;
            };
            // Quotes
            case ASCII_GRAVE;
            case ASCII_QUOTE;
            case ASCII_DOUBLE_QUOTE: {
                // Drop inQuotes mode if closing quote found
                if (_inQuotes && _char == _openQuoteChar) exitWith {
                    DBG_1("(parseOnelinerStructure) [inQuotes] End of quoted sequence at position %1 (exit inQuotes mode).", _i);
                    _inQuotes = false;
                    _openQuoteChar = -1;
                };
                // Enable inQuotes mode if not yet enabled
                if (!_inQuotes) exitWith {
                    DBG_1("(parseOnelinerStructure) [inQuotes] Start of quoted sequence at position %1. (start inQuotes mode)", _i);
                    _inQuotes = true;
                    _openQuoteChar = _char;
                };
            };
            // Brackets
            case ASCII_PARENTHESES_OPEN;
            case ASCII_CURLY_BRACKET_OPEN;
            case ASCII_SQUARE_BRACKET_OPEN: {
                if (_inQuotes) exitWith {}; // Ignore brackets inside the quotes
                // Another nested structure found - just update depth counter
                if (_inBracket && _char == _openBracketChar) exitWith {
                    _inBracketsDepth = _inBracketsDepth + 1;
                    DBG_2("(parseOnelinerStructure) [inBracket] Nested brackets start at position %1 (nested level %2).", _i, _inBracketsDepth);
                };
                // First bracket occurance - engage inBracket mode
                if (!_inBracket) exitWith {
                    DBG_1("(parseOnelinerStructure) [inBracket] Start of brackets sequence at position %1 (start inBrackets mode)", _i);
                    _inBracket = true;
                    _inBracketsDepth = _inBracketsDepth + 1;
                    _openBracketChar = _char;
                };
            };
            case ASCII_PARENTHESES_CLOSE;
            case ASCII_CURLY_BRACKET_CLOSE;
            case ASCII_SQUARE_BRACKET_CLOSE: {
                if (_inQuotes) exitWith {}; // Ignore closing brackets inside the quotes

                DBG_1("(parseOnelinerStructure) [inBracket] Possible close bracket at pos %1.", _i);
                // In brackets and closing bracket is the same type as open one -- decrease depth
                if (_inBracket && _char == (_bracketsOpenCloseMap get _openBracketChar)) exitWith {
                    _inBracketsDepth = _inBracketsDepth - 1;
                    DBG_2("(parseOnelinerStructure) [inBracket] End of nested brackets sequence at position %1 (nested level %2).", _i, _inBracketsDepth);
                    // If it was the last bracket pair -- exit inBracket mode
                    if (_inBracketsDepth == 0) then {
                        _inBracket = false;
                       DBG_1("(parseOnelinerStructure) [inBracket] End of brackets sequence at position %1 (exit inBrackets mode).", _i);
                    };
                };
            };
        };

        _item pushBack _char;
    };

    if (_mode == ONELINER_HASHMAP) then {
        DBG_1("(parseOnelinerStructure) Creating hash map from an array %1", _onelinerConverted);
        _onelinerConverted = createHashMapFromArray _onelinerConverted;
    };

    (_onelinerConverted)
};

private _fnc_checkIsOneliner = {
    // Checks value to be a onliner structure (array, hashmap, expression or code)

    params ["_value"];
    DBG_1("(checkIsOneliner) Params: %1", _this);

    if (_value isEqualTo "") exitWith { "STRING" };

    private _asChars = toArray _value;
    private _first = _asChars select 0;
    private _last = _asChars select (count _asChars - 1);
    private _sameChars = _first == _last;

    DBG_3("(checkIsOneliner) Value: %1. First: %2. Last: %3", _value, toString [_first], toString [_last]);

    // Quoted STRING case - unwrap quotes and return: "My string"
    (_sameChars && _first in STRING_QUOTES_ASCII)
    // Code case: { hint "Kek" }
    || (_first == CODE_PREFIX && _last == CODE_POSTIFX)
    // Array case: [item1, item2]
    || (_first == ARRAY_PREFIX && _last == ARRAY_POSTFIX)
    // HashMap case: (john: Doe, age: 33)
    || (_first == HASHMAP_PREFIX && _last == HASHMAP_POSTFIX)
    // Expression case: `date select 2`
    || (_sameChars && _first == EXPRESSION_PERFIX_ASCII)
};

private _fnc_parseValueType = {
    // Parse setting value. Rules:
    // - String --> quoted OR any text that not match rules below
    // - Boolean --> value is equal to true/false AND not quoted
    // - Scalar --> consists of only digit symbols or separators AND not quoted
    // - Code --> first and last symbol are { } AND not quoted
    // - Expression --> first and last symbols are ` AND not quoted
    // - Array --> first and last symbols are [ ] AND not quoted
    // - HashMap --> first and last symbols are ( ) AND not quoted
    // - Variable --> first and last symbols are <> OR (missionNamespace has value AND not quoted)
    // - Side --> value is one of the sides list AND not quoted
    // - Reference --> first symbol is * AND not quoted
    // - nil --> 'nil' value
    // - null --> one of null types names (objNull, grpNull, locationNull)

    params ["_value"];
    DBG_1("(parseValueType) Params: %1", _this);

    if (_value isEqualTo "") exitWith {
        DBG("(parseValueType) Value parsed to STRING (empty).");
        ""
    };

    private _asChars = toArray _value;
    private _first = _asChars # 0;
    private _last = _asChars select (count _asChars - 1);
    private _sameChars = _first == _last;

    DBG_3("(parseValueType) Value: %1. First: %2. Last: %3", _value, toString [_first], toString [_last]);

    // Quoted STRING case - unwrap quotes and return: "My string"
    if (_sameChars && _first in STRING_QUOTES_ASCII) exitWith {
        DBG("(parseValueType) Value parsed to STRING (explicit).");
        _value = [STRIP(_asChars)] call _fnc_removeEscaping;
        (_value)
    };

    // Boolean case: true
    if (toLower _value in ['true', 'false']) exitWith {
        DBG("(parseValueType) Value parsed to BOOLEAN.");
        (call compile _value)
    };

    // Scalar case: 23.32 or equations
    if (toLower _value regexMatch SCALAR_TYPE_REGEX) exitWith {
        DBG("(parseValueType) Value parsed to SCALAR.");
        (call compile _value)
    };

    // Code case: { hint "Kek" }
    if (_first == CODE_PREFIX && _last == CODE_POSTIFX) exitWith {
        DBG("(parseValueType) Value parsed to CODE.");
        (compile STRIP(_value))
    };

    // Array case: [item1, item2]
    if (_first == ARRAY_PREFIX && _last == ARRAY_POSTFIX) exitWith {
        DBG("(parseValueType) Value parsed to ONELINE ARRAY.");
        ([_value, ONELINER_ARRAY] call _fnc_parseOnelinerStructure)
    };

    // HashMap case: (john: Doe, age: 33)
    if (_first == HASHMAP_PREFIX && _last == HASHMAP_POSTFIX) exitWith {
        DBG("(parseValueType) Value parsed to ONELINE HASHMAP.");
        ([_value, ONELINER_HASHMAP] call _fnc_parseOnelinerStructure)
    };

    // Explicit Variable case: <spearhead>
    if (_first == VARIABLE_PREFIX && _last == VARIABLE_POSTFIX) exitWith {
        DBG("(parseValueType) Value parsed to VARIABLE (explicit).");
        private _var = missionNamespace getVariable [STRIP(_value), nil];
        if (isNil "_var") then {
            REPORT_ERROR_1(ERR_DATA_NIL_VARIABLE_REF, _forEachIndex, "Value is referencing to non-existing variable", STRIP(_value));
            nil
        } else {
            _var
        };
    };

    // Expression case: `date select 2`
    if (_sameChars && _first == EXPRESSION_PERFIX_ASCII) exitWith {
        DBG("(parseValueType) Value parsed to EXPRESSION.");
        (_args call compile STRIP(_value))
    };

    // Reference values - skip processing, as it should be resolved to actual value later
    if (_first == REF_PREFIX) exitWith {
        DBG("(parseValueType) Value parsed to REFERENCE.");
        _hasReferences = true;
        (format ["%1%2", REF_PREFIX_PROCESSED, _value select [1, count _value]])
    };

    // Side case: west
    private _sideId = SIDES_MAP findIf { _x # 0 == _value };
    if (_sideId > -1) exitWith {
        DBG("(parseValueType) Value parsed to SIDE.");
        (SIDES_MAP # _sideId # 1)
    };

    // Special data: nil
    if (_value == NIL_TYPE) exitWith {
        DBG("(parseValueType) Value parsed to NIL.");
        nil
    };

    // Special data - null: objNull/grpNull
    private _nullTypeId = NULL_TYPES findIf { _value == _x };
    if (_nullTypeId > -1) exitWith {
        DBG("(parseValueType) Value parsed to NULL.");
        (call compile _value)
    };

    // Otherwise - it's just a string without quoting
    DBG("(parseValueType) Value parsed to STRING.");

    _value = [_asChars] call _fnc_removeEscaping;
    (_value)
};

private _fnc_addSetting = {
    // Adds Key-Value pair to current active node
    params ["_key", "_value", ["_parseType", true]];
    private _node = [] call _fnc_getNode;
    DBG_3("(addSettings) Adding: %1 = %2 to node %3", _key, _value, CURRENT_NODE_KEY);

    private _parsedValue = if (_parseType) then { [_value] call _fnc_parseValueType } else { _value };
    _node set [_key, if (isNil "_parsedValue") then { nil } else { _parsedValue }];
};

private _fnc_linkRefValue = {
    /* Checks that given key-value is a reference and links it to the actual value.
    _node - (HashMap or Array) container of the key
    _key - (Any) HashMap's key or Array's index
    _value - (Any) key's/index value
    _recursiveStack - (Array) stack of references during recursive reference resolve (e.g. key is referencing to another reference)
    Return: nothing
    */
    params ["_node", "_key", "_value", ["_recursiveStack", []]];
    DBG_1("(fnc_linkRefValue) Params: %1", _this);

    if (count _recursiveStack >= RECURSIVE_COUNTER_LIMIT) exitWith {
        DBG("(fnc_linkRefValue) [ERROR:ERR_DATA_RECURSIVE_REFERENCE] Too many recursive calls for given reference!");
        REPORT_ERROR_NOLINE_2(ERR_DATA_RECURSIVE_REFERENCE, "Too many recursive calls for given reference!", _key, _recursiveStack)
    };

    // Refs are always strings started with *
    if (typename _value != "STRING" || { !IS_REF_VALUE(_value) }) exitWith {
        DBG("(fnc_linkRefValue) Not a reference. Exit.");
        continue
    };
    DBG("(fnc_linkRefValue) Value is a reference! Check for value on given reference");

    // Search for referenced key
    private _pair = format ["%1: %2", _key, _value];
    private _refPath = ((_value select [REF_PREFIX_PROCESSED_LENGTH, count _value]) splitString toString [REF_INFIX]) apply {
        [_x] call CBA_fnc_trim
    };
    private _refValue = _hash;
    DBG_1("(fnc_linkRefValue) Reference path: %1", _refPath);
    {
        private _nodeType = typename _refValue;
        DBG_2("(fnc_linkRefValue) -- Key: %1 for %2 node", _x, _nodeType);
        if (_nodeType == "ARRAY") then {
            if (_x isEqualTo str(parseNumber _x)) then {
                // Key is a number (array index)
                DBG("(fnc_linkRefValue) -- > Next step is Array index");
                _refValue = _refValue select parseNumber _x;
            } else {
                DBG("(fnc_linkRefValue) [ERROR:ERR_DATA_NAN_INDEX_REFERENECE] Wrong array index (non-integer)!");
                REPORT_ERROR_NOLINE_1(ERR_DATA_NAN_INDEX_REFERENECE,"Array index is not a number in Reference path", _pair);
                _refValue = nil;
            };
        } else {
            // Key is not a number (hashmap key)
            DBG("(fnc_linkRefValue) -- > Next step is HashMap key");
            _refValue = _refValue get _x;
        };

        if (isNil "_refValue") exitWith {
            DBG_1("(fnc_linkRefValue) -- ERROR -- Referenced to non-existing node [%1]", _x);
            REPORT_ERROR_NOLINE_2(ERR_DATA_NIL_REFERENCE, "Referencing to non-existing node!", _pair, _x);
        };

        DBG_2("(fnc_linkRefValue) -- >> %1 = %2", _x, _refValue);
    } forEach _refPath;

    if (isNil "_refValue") exitWith {};
    private _refType = typename _refValue;

    if (_refType == "STRING" && { IS_REF_VALUE(_refValue) }) exitWith {
        DBG_1("(fnc_linkRefValue) Ref value is another reference!. Value: %1", _refValue);
        _recursiveStack pushBack _value;
        [_node, _key, _refValue, _recursiveStack] call _fnc_linkRefValue;
    };
    DBG_2("(fnc_linkRefValue) Ref value found. Value: %1 (type: %2)", _refValue, _refType);

    // Set value
    if (_refType in ["ARRAY","HASHMAP"]) then {
        _node set [_key, +_refValue];
    } else {
        _node set [_key, _refValue];
    };
    DBG_2("(fnc_linkRefValue) Ref Linked! Key %1 = %2", _key, if (typename _node == "HASHMAP") then {_node get _key} else {_node select _key});
};

private _fnc_findRefValues = {
    /* Checks for containers in current node and links refereneces.
       _node - (HashMap or Array) container to check
       _key - (Any) HashMap's key or array index to check
       Return: nothing
    */
    params ["_node", "_key"];
    DBG_1("(fnc_findRefValues) Params: %1", _this);

    private _data = if (typename _node == "HASHMAP") then { _node get _key } else { _node select _key };
    if (isNil "_data") exitWith {};
    private _type = typename _data;

    DBG_4("(fnc_findRefValues) Node type: %1. Key: %2. Data: %3 (type: %4)", typename _node, _key, _data, _type);

    switch _type do {
        case "HASHMAP": {
            DBG("(fnc_findRefValues) Value is HashMap. Invoke findAndLinkRefValues...");
            [_data] call _fnc_findAndLinkRefValues;
        };
        case "ARRAY": {
            DBG("(fnc_findRefValues) Value is Array. Invoke findRefValues for each array item...");
            {
                [_data, _forEachIndex] call _fnc_findRefValues;
            } forEach _data;
        };
        default {
            DBG("(fnc_findRefValues) Value is meaningful. Invoke fnc_linkRefValue...");
            [_node, _key, _data] call _fnc_linkRefValue;
        };
    };
};

private _fnc_findAndLinkRefValues = {
    /* Recursive search through settings hash, find references and link 'em
       _node -- (HashMap) hashmap to search
       Return: none
    */
    params ["_node"];

    DBG_1("(findAndLinkRefValues) Params: %1", _this);
    {
        [_node, _x] call _fnc_findRefValues;
    } forEach (keys _node) - [ERRORS_NODE, SOURCE_NODE];
};

private _fnc_convertToArray = {
    {
        private _val = [_hash, _x] call dzn_fnc_getByPath;
        DBG_2("(fnc_findAndConvertToArray) Path: %1. Value: %2", _x, _val);

        private _arr = [];
        for "_i" from 0 to (count _val)-1 do {
            _arr set [_i, (_val get _i)];
        };

        [_hash, _x, _arr] call dzn_fnc_setByPath;

        DBG_2("(fnc_findAndConvertToArray) Converted: %1. Value: %2", [_hash, _x] call dzn_fnc_getByPath);
    } forEach _arrayNodes;
};

private _fnc_removeEscaping = {
    // Removes escaping char (backslash \ in front of the escapable char) from the given line
    params ["_chars"];

    if !(ASCII_BACKSLASH in _chars) exitWith { toString _chars };

    private _size = count _chars - 2;
    private _escapedSymbols = [
        ASCII_ASTERISK, // * - Reference
        ASCII_LT, ASCII_GT, // < > - Variable
        ASCII_SQUARE_BRACKET_OPEN, ASCII_SQUARE_BRACKET_CLOSE, // [ ] - array block
        ASCII_PARENTHESES_OPEN, ASCII_PARENTHESES_CLOSE, // ( ) - hashmap block
        ASCII_CURLY_BRACKET_OPEN, ASCII_CURLY_BRACKET_CLOSE, // { } - Code block
        ASCII_GRAVE, // ` - Expression
        ASCII_VERTICAL_LINE, ASCII_CARET // |, ^ - Multiline block start
    ];
    private _escapingsAt = [];

    // Find escpaing symbols (the one that placed in front of escaped symbols)
    for "_i" from 0 to _size do {
        private _char = _chars # _i;
        private _nextChar = _chars # (_i + 1);
        if (_char == ASCII_BACKSLASH && { _nextChar in _escapedSymbols }) then {
            DBG_1("(fnc_removeEscaping) Escaping found at %1", _i);
            _escapingsAt pushBack _i;
        };
    };

    // Remove escaping symbols
    reverse _escapingsAt;
    { _chars deleteAt _x; } forEach _escapingsAt;

    DBG_1("(fnc_removeEscaping) Result: %1", (toString _chars));
    (toString _chars)
};

private _fnc_parseLine = {
    // Parses given line according to current mode
    if (_mode != MODE_MULTILINE_TEXT && _line == EOF) exitWith {};

    switch _mode do {
        case MODE_ROOT: {
            if (_actualIndent != 0) exitWith {
                DBG_1("(ROOT) [ERROR:ERR_INDENT_UNEXPECTED_ROOT] Error - unexpected indent: %1", _actualIndent);
                REPORT_ERROR(ERR_INDENT_UNEXPECTED_ROOT, _forEachIndex, "Unexpected indent on parsing root element")
            };

            DBG_1("(ROOT) Line: [%1]", _line);
            private _parsed = [_line] call _fnc_parseKeyValuePair;
            DBG_1("(ROOT) Parsed: %1", _parsed);
            if (_parsed isEqualTo []) exitWith {
                DBG_1("(ROOT) [ERROR:ERR_DATA_MALFORMED] Unknown markup at index: %1", _forEachIndex);
                REPORT_ERROR(ERR_DATA_MALFORMED, _forEachIndex, "Unknown markup in line (not a key-value pair/section/array)");
            };
            _parsed params ["_key", "_value"];

            // Object found
            if (_value isEqualTo "") exitWith {
                [_key] call _fnc_addNode;
                _mode = MODE_NESTED;
                DBG("(ROOT) #PARSED# Is start of the section. Switching to MODE_NESTED");
            };

            // Multiline text is found - add node and switch to multiline mode
            if (IS_MULTILINE_START(_value)) exitWith {
                DBG("(ROOT) #PARSED# Start of the multiline text section. Switching to MODE_MULTILINE_TEXT");
                _mode = MODE_MULTILINE_TEXT;
                [_key, _actualIndent, _value] call _fnc_initMultilineBuffer;
            };

            // Simple key-value pair
            DBG("(ROOT) #PARSED# Adding key-value pair to hash.");
            [_key, _value] call _fnc_addSetting;
        };
        case MODE_MULTILINE_TEXT: {
            private _expectedIndent = _hash get MULTILINE_INDENT_NODE;
            if (_actualIndent < _expectedIndent) exitWith {
                DBG("(MULTILINE) End of the multiline text.");

                // Saving multiline data

                private _key = _hash get MULTILINE_KEY_NODE;
                private _linesList = _hash get MULTILINE_VALUE_NODE;

                // Clean tailing empty lines
                for "_i" from (count _linesList - 1) to 0 step -1 do {
                    if (_linesList # _i == "") then {
                        _linesList deleteAt _i;
                    } else {
                        break;
                    };
                };
                // Compose lines according to selected mode
                private _value = switch (_hash get MULTILINE_MODE_NODE) do {
                    case MULTILINE_MODE_NEWLINES: { _linesList joinString endl };
                    case MULTILINE_MODE_FOLDED: { _linesList joinString " " };
                    case MULTILINE_MODE_CODE: { compile (_linesList joinString endl) };
                };
                DBG_2("(MULTILINE) Key: %1, Composed: %2", _key, _value);

                if (_key isEqualTo "") then {
                    // Multiline in array item
                    private _arrayKey = [_value, false] call _fnc_addArrayItem;
                    DBG_1("(MULTILINE.ARRAY) Simple array item added with index %1", _arrayKey);
                } else {
                    // Multiline in key
                    [_key, _value, false] call _fnc_addSetting;
                    DBG_1("(MULTILINE.PAIR) Added to key %1", _key);
                };

                // Drop multiline buffer
                _hash deleteAt MULTILINE_KEY_NODE;
                _hash deleteAt MULTILINE_VALUE_NODE;
                _hash deleteAt MULTILINE_INDENT_NODE;
                _hash deleteAt MULTILINE_MODE_NODE;

                // Change mode of the parser
                if (_actualIndent == 0) then {
                    DBG("(MULTILINE) Returning to MODE_ROOT");
                    _hashNodesRoute = [];
                    _mode = MODE_ROOT;
                } else {
                    DBG("(MULTILINE) Returning to MODE_NESTED");
                    _mode = MODE_NESTED;
                };

                [] call _fnc_parseLine;
            };

            // Trim left for a number of the expected indent chars
            private _trimmed = _line select [_expectedIndent, count _line];
            DBG_1("(MULTILINE) Adding trimmed line [%1] to buffer", _trimmed);
            (_hash get MULTILINE_VALUE_NODE) pushBack _trimmed;
        };
        case MODE_NESTED: {
            if (_actualIndent == 0) exitWith {
                DBG("(NESTED) End of the all nested objects");
                _hashNodesRoute = [];
                _mode = MODE_ROOT;
                [] call _fnc_parseLine;
            };

            if (_actualIndent % 2 > 0) exitWith {
                DBG_1("(NESTED) [ERROR:ERR_INDENT_MALFORMED] Indent malformed (%1 is not a multiple of 2)", _actualIndent);
                REPORT_ERROR(ERR_INDENT_MALFORMED, _forEachIndex, "Indent malformed (not a multiple of 2)");
            };

            private _calculated = call _fnc_calculateExpectedIndent;
            private _indentDiff = _calculated - _actualIndent;

            DBG_2("(NESTED) Calcualted indent: %1 (diff: %2)", _calculated, _indentDiff);

            private _closedCount = ceil (_indentDiff / INDENT_DEFAULT);
            if (_indentDiff < 0 || (_indentDiff > 0 && _closedCount == 0)) exitWith {
                DBG_2("(NESTED) [ERROR:ERR_INDENT_UNEXPECTED_NESTED] Unexpected indent for nested item (expected %1, but actual is %2) ", _calculated, _actualIndent);
                REPORT_ERROR(ERR_INDENT_UNEXPECTED_NESTED, _forEachIndex, "Unexpected indent for nested item (expected " + str _calculated + ", but actual is " + str _actualIndent);
            };

            if (_indentDiff > 0) then {
                DBG_1("(NESTED) End of the current %1 nested object(s).", _closedCount);
                DBG_2("(NESTED) Going to delete from index %1 (%2)", (count _hashNodesRoute - 1 * _closedCount), _hashNodesRoute select (count _hashNodesRoute - 1 * _closedCount));
                _hashNodesRoute deleteRange [count _hashNodesRoute - 1 * _closedCount, _closedCount];
                DBG_1("(NESTED) Nodes route now: %1", _hashNodesRoute);
            };

            _line = [_line] call CBA_fnc_trim;
            _chars = toArray _line;
            _startsWith = _chars # 0;

            // Array case
            if (_startsWith == ASCII_MINUS) exitWith {
                DBG("(NESTED) Nested element is array item");
                _mode = MODE_NESTED_ARRAY;
                DBG_1("(NESTED) Bookmarking array node %1", _hashNodesRoute);
                if !(IS_IN_ARRAY_NODE) then {
                    _arrayNodes pushBackUnique +_hashNodesRoute;
                };
                [] call _fnc_parseLine;
            };

            // Object case
            DBG("(NESTED) Nested element is object");
            _mode = MODE_NESTED_OBJECT;
            [] call _fnc_parseLine;
        };
        case MODE_NESTED_ARRAY: {
            DBG_1("(NESTED.ARRAY) Line: %1", _line);
            _mode = MODE_NESTED;

            _line = [_line, "- "] call CBA_fnc_leftTrim;

            DBG("(NESTED.ARRAY) Check for oneliner structure");
            private _isOneliner = [_line] call _fnc_checkIsOneliner;
            DBG_1("(NESTED.ARRAY) Is oneliner?: %1", _isOneliner);

            private _parsed = [_line] call _fnc_parseKeyValuePair;
            if (_isOneliner || _parsed isEqualTo []) exitWith {
                DBG("(NESTED.ARRAY) Nested array item case");
                if (IS_MULTILINE_START(_line)) then {
                    // Nested Multiline text is found in array
                    DBG("(NESTED.ARRAY) #PARSED# Start of the multiline text section. Swtiching to MODE_MULTILINE_TEXT");
                    _mode = MODE_MULTILINE_TEXT;
                    ["", _actualIndent + INDENT_ARRAY_NESTED, _line] call _fnc_initMultilineBuffer;
                } else {
                    // Simple array item: - itemX
                    if (IS_IN_ARRAY_NODE) then {
                        _hashNodesRoute deleteAt (count _hashNodesRoute - 1);
                        DBG_1("(NESTED.ARRAY) New array item, step back to array node. Nodes are: %1", _hashNodesRoute);
                    };
                    private _arrayKey = [[_line] call _fnc_parseValueType] call _fnc_addArrayItem;
                    DBG_1("(NESTED.ARRAY) #PARSED# Simple array item: %1", _arrayKey);
                };
            };

            // Otherwise -- assosiated value or another nested thing: - item: ???
            _parsed params ["_key", "_value"];

            // Nested object: - weapons:
            //                    - some item1
            if (_value isEqualTo "") exitWith {
                DBG("(NESTED.ARRAY.SECTION) Nested section found. Creating array and add subnode to it");

                private _nestedNode = createHashMap;
                private _arrayKey = [_nestedNode] call _fnc_addArrayItem;
                _hashNodesRoute pushBack _arrayKey;

                [_key] call _fnc_addNode;
                DBG_1("(NESTED.ARRAY.SECTION) Nested section found. Nodes are: %1", _hashNodesRoute);
            };

            // Array-Nested object found: - item: value
            // ---

            if (IS_IN_ARRAY_NODE) then {
                /* Next array item found:
                   - key: value1
                     key2: value2
                   - key: value3    <--- thsi case - new array item detected
                */
                _hashNodesRoute deleteAt (count _hashNodesRoute - 1);
                DBG_1("(NESTED.ARRAY.OBJECT) New array item, step back to array node. Nodes are: %1", _hashNodesRoute);
            };

            private _nestedNode = createHashMap;
            private _arrayKey = [_nestedNode] call _fnc_addArrayItem;
            _hashNodesRoute pushBack _arrayKey;

            if (IS_MULTILINE_START(_value)) exitWith {
                DBG("(NESTED.ARRAY.OBJECT) #PARSED# Start of the multiline text section. Swtiching to MODE_MULTILINE_TEXT");
                _mode = MODE_MULTILINE_TEXT;
                [_key, _actualIndent + INDENT_ARRAY_NESTED, _value] call _fnc_initMultilineBuffer;
            };

            DBG("(NESTED.ARRAY.OBJECT) #PARSED# Key-value pair found.");
            [_key, _value] call _fnc_addSetting;
        };
        case MODE_NESTED_OBJECT: {
            DBG_1("(NESTED.OBJECT) Line: %1", _line);
            _mode = MODE_NESTED;

            private _parsed = [_line] call _fnc_parseKeyValuePair;
            if (_parsed isEqualTo []) exitWith {
                DBG("(NESTED) [ERROR:ERR_DATA_MALFORMED] Unknown markup in nested line (not a key-value pair/section/array)");
                REPORT_ERROR(ERR_DATA_MALFORMED, _forEachIndex, "Unknown markup in nested line (not a key-value pair/section/array).");
            };

            _parsed params ["_key", "_value"];
            // Item is header of nested
            if (_value == "") exitWith {
                [_key] call _fnc_addNode;
                DBG_1("(NESTED.SECTION) #PARSED# This is the header of new nested object: %1", _line);
            };

            // Multiline text is found - add node and switch to multiline mode
            if (IS_MULTILINE_START(_value)) exitWith {
                DBG("(NESTED) #PARSED# Start of the multiline text section. Swtiching to MODE_MULTILINE_TEXT");
                _mode = MODE_MULTILINE_TEXT;
                [_key, _actualIndent, _value] call _fnc_initMultilineBuffer;
            };

            // Item is key-value, just nested:
            DBG_1("(NESTED.SECTION) #PARSED# Nested key-value for node: %1", _hashNodesRoute);
            [_key, _value] call _fnc_addSetting;
        };
    };
};

// --- Main programm body
DBG("----------------------------------- PREPARING -----------------------------");
private _lines = if (_dataMode == MODE_PARSE_LINE) then {
    [_data]
} else {
    [_data] call _fnc_splitLines;
};
DBG_1("Lines count: %1", count _lines);
DBG("----------------------------------- PARSING -------------------------------");

if !(_lines findIf { _x != "" } > -1) exitWith {
    REPORT_ERROR_NOLINE(ERR_FILE_NO_CONTENT, 'File has no content (or commented)!');
    _hash
};

private _linesCount = count _lines - 1;
private _hashNodesRoute = [];
private _arrayNodes = [];
private _hasReferences = false;
private _mode = MODE_ROOT;

{
    private _line = _x;
    private _chars = toArray _line;
    private _startsWith = _chars # 0;
    private _actualIndent = 0;
    for "_i" from 0 to (count _chars)-1 do {
        if (_chars # _i != ASCII_SPACE) exitWith { _actualIndent = _i; };
    };
    DBG_3("Line %1: %2 [Indents: %3]", _forEachIndex+1, _line, _actualIndent);

    if ([_line] call CBA_fnc_trim isEqualTo "") then {
        if (_mode == MODE_MULTILINE_TEXT) then {
            if (_forEachIndex == _linesCount) exitWith {}; // Last line in file - not a piece of multiline

            private _multilineIndentCount = _hash get MULTILINE_INDENT_NODE;
            DBG("Empty line in multiline mode. Possible newline!");
            if (_actualIndent < _multilineIndentCount) then {
                for "_i" from 1 to _multilineIndentCount do { _chars pushBack ASCII_SPACE };
                _line = toString _chars;
                _actualIndent = _multilineIndentCount;
                DBG_1("Empty line adjusted: [%1]", _line);
            };
        } else {
            DBG_1("Line %1: Is empty. Skipped.", _forEachIndex+1);
            continue;
        };
    };

    [] call _fnc_parseLine;
} forEach _lines;

if (_dataMode == MODE_PARSE_LINE) then {
    // Move data from DATA_NODE to main hash, and remove data node
    private _node = _hash get DATA_NODE;
    _hash deleteAt DATA_NODE;
    _hash merge _node;
} else {
    // Trigger conversion to array for last nested array in the file
    [] call _fnc_convertToArray;

    // Link reference values
    if (_hasReferences) then {
        [_hash] call _fnc_findAndLinkRefValues;
    };
};


DBG("----------------------------------- FINISHED -----------------------------");
DBG_1("Hash: %1", _hash);

if (_printStatistics) then {
    private _timeSpent = diag_tickTime - _startAt;
    private _errorCount = count (_hash get ERRORS_NODE);
    LOG_3("Parsed file [%1] in %2 seconds. Error count: %3.", _input, _timeSpent, _errorCount);
};

(_hash)
