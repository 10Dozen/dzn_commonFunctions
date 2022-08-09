/*
 * [@Filename] call dzn_fnc_parseSettingsFile
 * Parses YAML-like settinsg file to HashMap..
 *
 * INPUT:
 * 0: STRING - path to file to parse
 *
 * OUTPUT:
 * 0: HASHMAP - map of the parsed settings. Each section will be available under it's key.
 *               Special keys are "#ERRORS" and "#SOURCE".
 *
 *              '#ERRORS' key - array of parsing errors in format:
 *              [_errorCode, _lineNo, _lineContent, _reason, (optional) _param1, ... , _paramN].
 *              where:
 *              _errorCode - (number) error code from \dzn_commonFunctions\functions\common\SettingsFileParser.hpp
 *              _lineNo - (number) line number (approximate)
 *              _lineContent - (string) content of the parsed line
 *              _reason - (string) human readable reason of the error
 *              _param1 - (any) additional parameter of the error. Optional.
 *
 *              '#SOURCE' key - string with path to parsed file (same as function argument).
 *
 * EXAMPLES:
 *      _settings = ["dzn_tSFramework\Modules\Chatter\Settings.yaml"] call dzn_fnc_parseSettingsFile
 */

#include "SettingsFileParser.hpp"

#define DEBUG true
#ifdef DEBUG
    #define LOG_PREFIX '[dzn_fnc_parseSettingsFile] PARSER: '
    #define LOG(MSG) diag_log text (LOG_PREFIX + MSG)
    #define LOG_1(MSG,ARG1) diag_log text format [LOG_PREFIX + MSG,ARG1]
    #define LOG_2(MSG,ARG1,ARG2) diag_log text format [LOG_PREFIX + MSG,ARG1,ARG2]
    #define LOG_3(MSG,ARG1,ARG2,ARG3) diag_log text format [LOG_PREFIX + MSG,ARG1,ARG2,ARG3]
    #define LOG_4(MSG,ARG1,ARG2,ARG3,ARG4) diag_log text format [LOG_PREFIX + MSG,ARG1,ARG2,ARG3,ARG4]
#endif

#define MODE_ROOT 0
#define MODE_NESTED 10

#define ONELINER_ARRAY 1000
#define ONELINER_HASHMAP 1001

#define CURRENT_NODE_KEY (if (count _hashNodesRoute > 0) then {_hashNodesRoute select (count _hashNodesRoute - 1)} else {""})
#define STRIP(X) (X select [1, count X - 2])

#define FORMAT_LINE_INFO(LINE_NO, MSG) format ["Line %1: %2", LINE_NO, MSG]
#define REPORT_ERROR_EMPTY(ERROR_CODE,MSG) (_hash get ERRORS_NODE) pushBack [ERROR_CODE, -1, '', MSG];
#define REPORT_ERROR(ERROR_CODE,LINE_NO,MSG) (_hash get ERRORS_NODE) pushBack [ERROR_CODE,LINE_NO+1,FORMAT_LINE_INFO(LINE_NO+1,_lines select LINE_NO),MSG]
#define REPORT_ERROR_1(ERROR_CODE,LINE_NO,MSG,ARG1) (_hash get ERRORS_NODE) pushBack [ERROR_CODE,LINE_NO+1,FORMAT_LINE_INFO(LINE_NO+1,_lines select LINE_NO),MSG,ARG1]
#define REPORT_ERROR_2(ERROR_CODE,LINE_NO,MSG,ARG1,ARG2) (_hash get ERRORS_NODE) pushBack [ERROR_CODE,LINE_NO+1,FORMAT_LINE_INFO(LINE_NO+1,_lines select LINE_NO),MSG,ARG2]

params ["_file"];

private _data = loadFile _file;
private _hash = createHashMap;
_hash set [SOURCE_NODE, _file];
_hash set [ERRORS_NODE, []];

if (count _data == 0) exitWith {
    diag_log text format ["[dzn_fnc_parseSettingsFile] Warning! File %1 is empty!", _file];
    REPORT_ERROR_EMPTY(ERR_FILE_EMPTY, 'File is empty!');
    _hash
};

forceUnicode 1;

// --- Functions
private _fnc_splitLines = {
    params ["_data"];
    private _chars = toArray _data;
    private _lines = [];
    private _line = [];

    for "_i" from 0 to (count _chars - 1) do {
        private _lineSize = count _line;
        if (_lineSize > 1 && { (_line select [_lineSize - 2, 2]) isEqualTo [13,10] }) then {
            private _normalizedLine = toString ([_line select [0, _lineSize - 2]] call _fnc_removeComment);
            LOG_1("(splitLines) Found and normalized: %1", _normalizedLine);
            _lines pushBack _normalizedLine;
            _line deleteRange [0, _lineSize];
        };
        _line pushBack (_chars # _i);
    };
    // Process EOF
    _lines pushBack toString (_line select [0, count _line - 2]);

    _lines
};

private _fnc_removeComment = {
    params ["_chars"];
    private _size = count _chars;
    private _commentStartedIndex = -1;
    private _escapedHashes = [];
    private _inQuotes = false;
    private _openQuotesChar = -1;
    private _inCode = false;
    private _inCodeDepth = 0;
    private ["_char"];

    for "_j" from 0 to _size-1 do {
        _char = _chars # _j;

        switch _char do {
            case ASCII_HASH: {
                if (_inQuotes || _inCode) exitWith { }; // Ignore hashes inside the quotes or code
                if (_j == 0) exitWith { _commentStartedIndex = _j; };
                if (_chars # (_j - 1) in [ASCII_SLASH, ASCII_BACKSLASH]) then {
                    _escapedHashes pushBack [_j - 1];
                } else {
                    _commentStartedIndex = _j;
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
                if (_inQuotes && _char == _openQuotesChar) exitWith {
                    _openQuotesChar = -1;
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
    { _chars deleteAt _x } forEach (reverse _escapedHashes);

    _chars
};

/*
private _fnc_removeComment = {
    params ["_line"];
    private _lineChars = toArray _line;
    private _commentStartedIndex = -1;
    private ["_char"];

    for "_i" from 0 to (count _lineChars)-1 do {
        _char = _lineChars # _i;
        if (_char == ASCII_HASH
            && (
                _i == 0
                || (_i > 0 && {_lineChars # (_i - 1) != ASCII_BACKSLASH }))
        ) exitWith {
            _commentStartedIndex = _i;
        };
    };

    if (_commentStartedIndex < 0) exitWith { _this };
    toString (_lineChars select [0, _commentStartedIndex]) splitString "\#" joinString "#"
};
*/

private _fnc_parseKeyValuePair = {
    params ["_line"];
    if !(":" in _line) exitWith {
        LOG("(parseKeyValuePair) -----------# No key definition found, this is not an key-value pair");
        []
    };
    private _parts = _line splitString ":";
    private _key = [_parts # 0] call CBA_fnc_trim;
    _parts deleteAt 0;
    private _value = [_parts joinString ":"] call CBA_fnc_trim;

    LOG_3("(parseKeyValuePair) -----------# #PARSED# Key: %2, Value: %3", _forEachIndex, _key, _value);
    [_key, _value]
};

private _fnc_addArrayItem = {
    params ["_item"];
    private _node = [] call _fnc_getNode;
    private _key = count keys _node;
    _node set [_key, _item];
    LOG_2("(addArrayItem) Adding array node %1. Nodes: %2", _key, _hashNodesRoute);

    LOG("----------- Add array item to hash node -------------");
    LOG_1("%1", values _node);
    LOG("------------------------------------------------------");

    (_key)
};

private _fnc_getNode = {
    params [["_nodes", _hashNodesRoute]];

    LOG_1("(getCurrentNode) Nodes: %1", _nodes);

    private _node = _hash;
    { _node = _node get _x; } forEach _nodes;
    _node
};

private _fnc_addNode = {
    params ["_key"];

    LOG_1("(addNode) Adding node: %1", _key);
    private _node = [] call _fnc_getNode;

    if (!isNil {_node get _key}) then {
        REPORT_ERROR(ERR_NODE_DUPLICATE, _forEachIndex, _line, "Duplicate node found!");
    };
    _node set [_key, createHashMap];
    _hashNodesRoute pushBack _key;
};

private _fnc_convertToArray = {
    private _key = CURRENT_NODE_KEY;
    private _subMap = [] call _fnc_getNode;
    private _subMapArrayNodesSize = { typename _x == "SCALAR" } count (keys _subMap);
    LOG_1("(convertToArray) Current node %1", _key);

    LOG_1("(convertToArray) Number of array nodes in current node: %1", _subMapArrayNodesSize);
    if (_subMapArrayNodesSize == 0) exitWith {
       LOG("(convertToArray) Current node is not an array. Skip.");
    };

    private _map = _hash;
    if (count _hashNodesRoute > 1) then {
        LOG_1("(convertToArray) There are %1 nodes in route...", count _hashNodesRoute);
        private _nodes = +_hashNodesRoute;
        _nodes deleteAt (count _nodes - 1);
        LOG_1("(convertToArray) Path to parent node %1", _nodes);
        _map = [_nodes] call _fnc_getNode;
    };

    LOG_2("(convertToArray) Parent node: %1. Converting map %2 to array", _map, _key);
    private _array = [];
    for "_i" from 0 to _subMapArrayNodesSize - 1 do {
        _array set [_i, _subMap get _i];
    };
    _map set [_key, _array];
};

private _fnc_calculateExpectedIndent = {
    private _expected = 0;
    {
        if (typename _x == "SCALAR") then {
            private _tline = [_line] call CBA_fnc_trim;
            if (_tline select [0,1] != "-") then {
                _expected = _expected + 2;
            };
        } else {
            _expected = _expected + 4;
        };
    } forEach _hashNodesRoute;

    _expected
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
    LOG_2("(parseOnelinerStructure) Oneliner: %1. Mode: %2", _oneliner, _mode);

    private _chars = toArray STRIP(_oneliner);
    private _lenght = count _chars;
    private _onelinerConverted = [];
    private _item = [];
    private _inQuotes = false;
    private _openQuoteChar = -1;

    for "_i" from 0 to _lenght do {
        private _c = if (_i != _lenght) then { _chars # _i } else { ASCII_COMMA };
        if (!_inQuotes) then {
            if (_c == ASCII_COMMA) then {
                private _itemStr = [toString _item] call CBA_fnc_trim;
                switch _mode do {
                    case ONELINER_ARRAY: {
                        LOG_1("(parseOnelinerStructure) Converting array item from %1", _itemStr);
                        private _v = [_itemStr] call _fnc_parseValueType;
                        _onelinerConverted set [count _onelinerConverted, _v];
                    };
                    case ONELINER_HASHMAP: {
                        LOG_1("(parseOnelinerStructure) Converting key-value pair item from %1", _itemStr);
                        private _parsed = [_itemStr] call _fnc_parseKeyValuePair;
                        LOG_1("(parseOnelinerStructure) Parsed: %1", _parsed);

                        if (_parsed isEqualTo []) then {
                            REPORT_ERROR_1(ERR_DATA_KEYVALUEPAIR_MALFORMED, _forEachIndex, _line, "One-liner HashMap pair is malformed", _itemStr);
                        } else {
                            LOG("(parseOnelinerStructure) XXX TEST");
                            _parsed params ["_k", "_v"];
                            LOG_2("(parseOnelinerStructure) Parsed K-V: %1 = %2", _k, _v);
                            if (_v isEqualTo "") then {
                                REPORT_ERROR_1(ERR_DATA_VALUE_MALFORMED, _forEachIndex, _line, "One-liner HashMap pair is missing value", _pairLine);
                            } else {
                                _v = [_v] call _fnc_parseValueType;
                                _onelinerConverted pushBack [_k, _v];
                            };
                        };
                    };
                };
                _item = [];
            } else {
                _item pushBack _c;
                if (_c in [ASCII_QUOTE, ASCII_DOUBLE_QUOTE]) then {
                    _inQuotes = true;
                    _openQuoteChar = _c;
                };
            }
        } else {
            _item pushBack _c;
            if (_c == _openQuoteChar) then {
                _inQuotes = false;
                _openQuoteChar = -1;
            };
        };
    };

    if (_mode == ONELINER_HASHMAP) then {
        LOG_1("(parseOnelinerStructure) Creating hash map from an array %1", _onelinerConverted);
        _onelinerConverted = createHashMapFromArray _onelinerConverted;
    };

    (_onelinerConverted)
};

private _fnc_parseValueType = {
    // Parse setting value. Rules:
    // - String --> quoted OR any text that not match rules below
    // - Boolean --> value is equal to true/false AND not quoted
    // - Scalar --> consists of only digit symbols or separators AND not quoted
    // - Code --> first and last symbol are { } AND not quoted
    // - Array --> first and last symbols are [ ] AND not quoted
    // - HashMap --> first and last symbols are ( ) AND not quoted
    // - Variable --> first and last symbols are <> OR (missionNamespace has value AND not quoted)
    // - Side --> value is one of the sides list AND not quoted
    // - nil --> 'nil' value
    // - null --> one of null types names (objNull, grpNull, locationNull)

    params ["_value"];

    private _asChars = toArray _value;
    private _first = _asChars # 0;
    private _last = _asChars select (count _asChars - 1);
    private _sameChars = _first == _last;

    LOG_3("(parseValueType) Value: %1. First: %2. Last: %3", _value, toString [_first], toString [_last]);

    // Quoted STRING case - unwrap quotes and return: "My string"
    if (_sameChars && _first in STRING_QUOTES_ASCII) exitWith {
        LOG("(parseValueType) Value parsed to STRING (quoted).");
        STRIP(_value)
    };

    // Boolean case: true
    if (toLower _value in ['true', 'false']) exitWith {
        LOG("(parseValueType) Value parsed to BOOLEAN.");
        (call compile _value)
    };

    // Scalar case: 23.32 or equations
    if (toLower _value regexMatch SCALAR_TYPE_REGEX) exitWith {
        LOG("(parseValueType) Value parsed to SCALAR.");
        (call compile _value)
    };

    // Code case: { hint "Kek" }
    if (_first == CODE_PREFIX && _last == CODE_POSTIFX) exitWith {
        LOG("(parseValueType) Value parsed to CODE.");
        (compile STRIP(_value))
    };

    // Array case: [item1, item2]
    if (_first == ARRAY_PREFIX && _last == ARRAY_POSTFIX) exitWith {
        LOG("(parseValueType) Value parsed to ONELINE ARRAY.");
        ([_value, ONELINER_ARRAY] call _fnc_parseOnelinerStructure)
    };

    // HashMap case: (john: Doe, age: 33)
    if (_first == HASHMAP_PREFIX && _last == HASHMAP_POSTFIX) exitWith {
        LOG("(parseValueType) Value parsed to ONELINE HASHMAP.");
        ([_value, ONELINER_HASHMAP] call _fnc_parseOnelinerStructure)
    };

    // Explicit Variable case: <spearhead>
    if (_first == VARIABLE_PREFIX && _last == VARIABLE_POSTFIX) exitWith {
        LOG("(parseValueType) Value parsed to VARIABLE (explicit).");
        private _var = missionNamespace getVariable [STRIP(_value), nil];
        if (isNil "_var") then {
            REPORT_ERROR_1(ERR_DATA_NIL_VARIABLE_REF, _forEachIndex, _line, "Value is referencing to non-existing variable", STRIP(_value));
            nil
        } else {
            _var
        };
    };

    // Evaluiate case: `date select 2`
    if (_sameChars && _first == EVAL_PERFIX_ASCII) exitWith {
        LOG("(parseValueType) Value parsed to EVALUATE.");
        (call compile STRIP(_value))
    };

    // Side case: west
    private _sideId = SIDES_MAP findIf { _x # 0 == _value };
    if (_sideId > -1) exitWith {
        LOG("(parseValueType) Value parsed to SIDE.");
        (SIDES_MAP # _sideId # 1)
    };

    // Implicit Variable case: spearhead
    private _var = missionNamespace getVariable [_value, nil];
    if (!isNil "_var") exitWith {
        LOG("(parseValueType) Value parsed to VARIABLE (impicit).");
        (_var)
    };

    // Special data: nil
    if (_value == NIL_TYPE) exitWith {
        LOG("(parseValueType) Value parsed to NIL.");
        nil
    };

    // Special data - null: objNull/grpNull
    private _nullTypeId = NULL_TYPES findIf { _value == _x };
    if (_nullTypeId > -1) exitWith {
        LOG("(parseValueType) Value parsed to NULL.");
        (call compile _value)
    };

    // Otherwise - it's just a string without quoting
    LOG("(parseValueType) Value parsed to STRING.");
    (_value)
};

private _fnc_addSetting = {
    params ["_key", "_value"];
    private _node = [] call _fnc_getNode;
    LOG_3("(addSettings) Adding: %1 = %2 to node %3", _key, _value, CURRENT_NODE_KEY);

    private _parsedValue = [_value] call _fnc_parseValueType;
    _node set [_key, _parsedValue];
};

private _fnc_parseLine = {
    // params ["_line", "_chars", "_startsWith", "_expectedIndent", "_actualIndent"];
    switch _mode do {
        case MODE_ROOT: {
            if (_actualIndent != 0) exitWith {
                LOG_1("(ROOT) Error - unexpected indent: %1", _actualIndent);
                REPORT_ERROR(ERR_INDENT_UNEXPECTED_ROOT,_forEachIndex, _line, "Unexpected indent on parsing root element")
            };
            if (_line isEqualTo "") exitWith {
                LOG("(ROOT) Line is a comment or empty");
            };

            private _parsed = [_line] call _fnc_parseKeyValuePair;
            if (_parsed isEqualTo []) exitWith {
                REPORT_ERROR(ERR_DATA_MALFORMED, _forEachIndex, _line, "Unknown markup in line (not a key-value pair/section/array).")
            };
            _parsed params ["_key", "_value"];

            // Object found
            if (_value isEqualTo "") exitWith {
                LOG("(ROOT) #PARSED# Is start of the section. Switching to MODE_NESTED");
                _mode = MODE_NESTED;
                [_key] call _fnc_addNode
            };

            // Simple key-value pair
            LOG("(ROOT) #PARSED# Adding key-value pair to hash.");
            [_key, _value] call _fnc_addSetting;
        };
        case MODE_NESTED: {
            if (_line isEqualTo "") exitWith {
                LOG("(NESTED) Line is a comment or empty");
            };
            if (_actualIndent == 0) exitWith {
                LOG("(NESTED) End of the all nested objects");
                while { _hashNodesRoute isNotEqualTo [] } do {
                    LOG("(NESTED) Looping back through nodes route...");
                    [] call _fnc_convertToArray;
                    _hashNodesRoute deleteAt (count _hashNodesRoute - 1);
                };
                _mode = MODE_ROOT;
                call _fnc_parseLine;
            };

            if (_actualIndent % 2 > 0) then {
                REPORT_ERROR(ERR_INDENT_MALFORMED,_forEachIndex, _line, "Indent malformed (not a multiple of 4)");
            } else {
                private _calculated = call _fnc_calculateExpectedIndent;
                if (_actualIndent != _calculated) then {
                    REPORT_ERROR(ERR_INDENT_UNEXPECTED_NESTED, _forEachIndex, _line, "Indent is different from expected (actual: " + str _actualIndent + ", expected: " + str _calculated + ")");
                };
            };
            private _indentClosed = floor ((_actualIndent - _expectedIndent) / 4);
            LOG_1("(NESTED) Closed indent: %1.", _indentClosed);
            if (_indentClosed > 1) exitwith {
                LOG_2("(NESTED) Error - unexpected indent: %1 expected, but %2 found. Switching to MODE_ROOT.", _expectedIndent, _actualIndent);
                REPORT_ERROR(ERR_INDENT_UNEXPECTED_NESTED, _forEachIndex, _line, "Unexpected indent on parsing nested element");
                [] call _fnc_convertToArray;
                _hashNodesRoute = [];
                _mode = MODE_ROOT;
                call _fnc_parseLine;
            };

            if (_indentClosed != 0) then {
                LOG_1("(NESTED) End of the current nested object. Closing %1 sections.", _indentClosed);
                _hashNodesRoute deleteAt (count _hashNodesRoute - 1 * abs(_indentClosed));
            };

            _line = [_line] call CBA_fnc_trim;
            _chars = toArray _line;
            _startsWith = _chars # 0;

            // Array case
            if (_startsWith == ASCII_MINUS) exitWith {
                LOG("(NESTED.ARRAY) Nested element is array item");

                _line = [_line, "- "] call CBA_fnc_leftTrim;
                private _parsed = [_line] call _fnc_parseKeyValuePair;
                if (_parsed isEqualTo []) exitWith {
                    // Simple array item: - itemX
                    private _arrayKey = [[_line] call _fnc_parseValueType] call _fnc_addArrayItem;
                    LOG_1("(NESTED.ARRAY) #PARSED# Simple array item: %1", _arrayKey);
                };

                // Otherwise -- assosiated value or another nested thing: - item: ???
                _parsed params ["_key", "_value"];

                // Nested array/object: - weapons:
                //                          - some item1
                if (_value isEqualTo "") exitWith {
                    [_key] call _fnc_addNode;
                    LOG_1("(NESTED.ARRAY.SECTION) Nested section found. Nodes are: %1", _hashNodesRoute);
                };

                // Array-Nested object found: - item: value
                if (typename CURRENT_NODE_KEY == "SCALAR") then {
                    /* - key: value1
                         key2: value2
                       - key: value3    <--- thsi case - new array item detected
                    */
                    _hashNodesRoute deleteAt (count _hashNodesRoute - 1);
                    LOG_1("(NESTED.ARRAY.OBJECT) New array item, step back to array node. Nodes are: %1", _hashNodesRoute);
                };

                private _nestedNode = createHashMap;
                private _arrayKey = [_nestedNode] call _fnc_addArrayItem;
                _hashNodesRoute pushBack _arrayKey;

                LOG("(NESTED.ARRAY.OBJECT) #PARSED# Key-value pair found.");
                [_key, _value] call _fnc_addSetting;
            };

            // Object case
            private _parsed = [_line] call _fnc_parseKeyValuePair;
            if (_parsed isEqualTo []) exitWith {
                REPORT_ERROR(ERR_DATA_MALFORMED,_forEachIndex,"Unknown markup in nested line (not a key-value pair/section/array).");
            };

            _parsed params ["_key", "_value"];
            // Item is header of nested
            if (_value == "") exitWith {
                [_key] call _fnc_addNode;
                LOG_1("(NESTED.SECTION) #PARSED# This is the header of new nested object: %1", _line);
            };

            // Item is key-value, just nested:
            LOG_1("(NESTED.SECTION) #PARSED# Nested key-value for node: %1", _hashNodesRoute);
            [_key, _value] call _fnc_addSetting;
        };
    };
};

// --- Main programm body
private _lines = [_data] call _fnc_splitLines;
LOG_1("Lines: %1", _lines);

if !(_lines findIf { _x != "" } > 0) exitWith {
    REPORT_ERROR_EMPTY(ERR_FILE_NO_CONTENT, 'File has no content (or commented)!');
    _hash
};

private _hashNodesRoute = [];
private _mode = MODE_ROOT;

{
    private _line = _x;
    private _chars = toArray _line;
    private _expectedIndent = 4 * ({ typename _x != "SCALAR" } count _hashNodesRoute);
    private _actualIndent = 0;
    for "_i" from 0 to (count toArray _line)-1 do {
        if (_chars # _i != ASCII_SPACE) exitWith { _actualIndent = _i; };
    };
    LOG_3("Line %1: %2 [Indents: %3]", _forEachIndex+1, _line, _actualIndent);

    // Clear comments if present
    // _line = _x call _fnc_removeComment;
    if ([_line] call CBA_fnc_trim isEqualTo "") then {
        LOG_1("Line %1: Is empty. Skipped.", _forEachIndex+1);
        continue
    };
    _chars = toArray _line;
    private _startsWith = _chars # 0;

    call _fnc_parseLine;
} forEach _lines;

[] call _fnc_convertToArray; // Trigger conversion to array for last nested array in the file

LOG("----------------------------------- FINISHED -----------------------------");
LOG_1("Hash: %1", _hash);

_hash
