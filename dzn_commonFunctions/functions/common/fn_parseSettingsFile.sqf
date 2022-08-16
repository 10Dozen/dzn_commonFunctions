/*
 * [@Filename, @Preprocess?] call dzn_fnc_parseSettingsFile
 * Parses YAML-like settinsg file to HashMap..
 *
 * INPUT:
 * 0: STRING - path to file to parse
 * 1: BOOL - flag to preprocess file and apply SQF preprocesor commands (e.g. includes, defines, etc.)
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
#define IS_REF_VALUE(X) (X select [0,1] == toString [REF_PREFIX])

// Error reporting
#define REPORT_ERROR_NOLINE(ERROR_CODE, MSG) (_hash get ERRORS_NODE) pushBack [ERROR_CODE, -1, '', MSG];
#define REPORT_ERROR_NOLINE_1(ERROR_CODE, MSG, ARG1) (_hash get ERRORS_NODE) pushBack [ERROR_CODE, -1, '', MSG, ARG1];
#define REPORT_ERROR_NOLINE_2(ERROR_CODE, MSG, ARG1, ARG2) (_hash get ERRORS_NODE) pushBack [ERROR_CODE, -1, '', MSG, ARG1, ARG2];

#define FORMAT_LINE_INFO(LINE_NO, MSG) format ["Line %1: %2", LINE_NO, MSG]
#define REPORT_ERROR(ERROR_CODE, LINE_NO, MSG) (_hash get ERRORS_NODE) pushBack [ERROR_CODE,LINE_NO+1,FORMAT_LINE_INFO(LINE_NO+1,_lines select LINE_NO),MSG]
#define REPORT_ERROR_1(ERROR_CODE, LINE_NO, MSG, ARG1) (_hash get ERRORS_NODE) pushBack [ERROR_CODE,LINE_NO+1,FORMAT_LINE_INFO(LINE_NO+1,_lines select LINE_NO),MSG,ARG1]
#define REPORT_ERROR_2(ERROR_CODE, LINE_NO, MSG, ARG1, ARG2) (_hash get ERRORS_NODE) pushBack [ERROR_CODE,LINE_NO+1,FORMAT_LINE_INFO(LINE_NO+1,_lines select LINE_NO),MSG,ARG2]

params ["_file", ["_preprocess", false]];

private _data = if (_preprocess) then {
    preprocessFile _file
} else {
    loadFile _file
};
private _hash = createHashMap;
_hash set [SOURCE_NODE, _file];
_hash set [ERRORS_NODE, []];

if (count _data == 0) exitWith {
    diag_log text format ["[dzn_fnc_parseSettingsFile] Warning! File %1 is empty!", _file];
    REPORT_ERROR_NOLINE(ERR_FILE_EMPTY, 'File is empty!');
    _hash
};

forceUnicode 1;

// --- Functions
private _fnc_splitLines = {
    params ["_data"];
    private _chars = toArray _data + [10,13];
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

    _lines
};

private _fnc_removeComment = {
    params ["_chars"];
    private _size = count _chars;
    private _commentStartedIndex = -1;
    private _escapedHashes = [];
    private _inQuotes = false;
    private _openQuoteChar = -1;
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
    { _chars deleteAt _x } forEach (reverse _escapedHashes);

    _chars
};

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

    LOG_1("(addNode) Node exists?: %1", !isNil {_node get _key});
    if (!isNil {_node get _key}) then {
        REPORT_ERROR(ERR_NODE_DUPLICATE, _forEachIndex, "Duplicate node found!");
    };
    _node set [_key, createHashMap];
    _hashNodesRoute pushBack _key;
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

    private _chars = toArray STRIP(_oneliner) + [ASCII_COMMA];
    private _lenght = count _chars;
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
    private ["_char"];

    for "_i" from 0 to _lenght - 1 do {
        _char = _chars # _i;
        switch _char do {
            // Item separator
            case ASCII_COMMA: {
                if (_inQuotes || _inBracket) exitWith {}; // Ignore comma inside quotes/brackets

                private _itemStr = [toString _item] call CBA_fnc_trim;
                LOG_1("(parseOnelinerStructure) Found item: %1", _itemStr);

                switch _mode do {
                    case ONELINER_ARRAY: {
                        LOG_1("(parseOnelinerStructure) Converting %1 to ARRAY item", _itemStr);
                        private _value = [_itemStr] call _fnc_parseValueType;

                        // Make a set, because pushBack ignores 'nil' value (which may be set by user or as result of nil variable reference)
                        _onelinerConverted set [count _onelinerConverted,  _value];
                    };
                    case ONELINER_HASHMAP: {
                        LOG_1("(parseOnelinerStructure) Converting %1 to HASHMAP key-value pair", _itemStr);
                        private _parsed = [_itemStr] call _fnc_parseKeyValuePair;
                        LOG_1("(parseOnelinerStructure) Parsed key-value: %1", _parsed);

                        if (_parsed isEqualTo []) exitWith {
                            REPORT_ERROR_1(ERR_DATA_KEYVALUEPAIR_MALFORMED, _forEachIndex, "One-liner HashMap pair is malformed", _itemStr);
                        };

                        _parsed params ["_key", "_value"];
                        _value = [_value] call _fnc_parseValueType;
                        _onelinerConverted pushBack [_key, _value];
                    };
                };

                _item = [];
                _char = nil;
            };
            // Quotes
            case ASCII_GRAVE;
            case ASCII_QUOTE;
            case ASCII_DOUBLE_QUOTE: {
                // Drop inQuotes mode if closing quote found
                if (_inQuotes && _char == _openQuoteChar) exitWith {
                    LOG_1("(parseOnelinerStructure) [inQuotes] End of quoted sequence at position %1 (exit inQuotes mode).", _i);
                    _inQuotes = false;
                    _openQuoteChar = -1;
                };
                // Enable inQuotes mode if not yet enabled
                if (!_inQuotes) exitWith {
                    LOG_1("(parseOnelinerStructure) [inQuotes] Start of quoted sequence at position %1. (start inQuotes mode)", _i);
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
                    LOG_2("(parseOnelinerStructure) [inBracket] Nested brackets start at position %1 (nested level %2).", _i, _inBracketsDepth);
                };
                // First bracket occurance - engage inBracket mode
                if (!_inBracket) exitWith {
                    LOG_1("(parseOnelinerStructure) [inBracket] Start of brackets sequence at position %1 (start inBrackets mode)", _i);
                    _inBracket = true;
                    _inBracketsDepth = _inBracketsDepth + 1;
                    _openBracketChar = _char;
                };
            };
            case ASCII_PARENTHESES_CLOSE;
            case ASCII_CURLY_BRACKET_CLOSE;
            case ASCII_SQUARE_BRACKET_CLOSE: {
                if (_inQuotes) exitWith {}; // Ignore closing brackets inside the quotes

                LOG_1("(parseOnelinerStructure) [inBracket] Possible close bracket at pos %1.", _i);
                // In brackets and closing bracket is the same type as open one -- decrease depth
                if (_inBracket && _char == (_bracketsOpenCloseMap get _openBracketChar)) exitWith {
                    _inBracketsDepth = _inBracketsDepth - 1;
                    LOG_2("(parseOnelinerStructure) [inBracket] End of nested brackets sequence at position %1 (nested level %2).", _i, _inBracketsDepth);
                    // If it was the last bracket pair -- exit inBracket mode
                    if (_inBracketsDepth == 0) then {
                        _inBracket = false;
                       LOG_1("(parseOnelinerStructure) [inBracket] End of brackets sequence at position %1 (exit inBrackets mode).", _i);
                    };
                };
            };
        };

        _item pushBack _char;
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
    LOG_1("(parseValueType) Params: %1", _this);

    if (_value isEqualTo "") exitWith {
        LOG("(parseValueType) Value parsed to STRING (empty).");
        ""
    };

    private _asChars = toArray _value;
    private _first = _asChars # 0;
    private _last = _asChars select (count _asChars - 1);
    private _sameChars = _first == _last;

    LOG_3("(parseValueType) Value: %1. First: %2. Last: %3", _value, toString [_first], toString [_last]);

    // Quoted STRING case - unwrap quotes and return: "My string"
    if (_sameChars && _first in STRING_QUOTES_ASCII) exitWith {
        LOG("(parseValueType) Value parsed to STRING (explicit).");
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
            REPORT_ERROR_1(ERR_DATA_NIL_VARIABLE_REF, _forEachIndex, "Value is referencing to non-existing variable", STRIP(_value));
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

    // Reference values - skip processing, as it should be resolved to actual value later
    if (_first == REF_PREFIX) exitWith {
        LOG("(parseValueType) Value parsed to REFERENCE.");
        _value
    };

    // Side case: west
    private _sideId = SIDES_MAP findIf { _x # 0 == _value };
    if (_sideId > -1) exitWith {
        LOG("(parseValueType) Value parsed to SIDE.");
        (SIDES_MAP # _sideId # 1)
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

    // Implicit Variable case: spearhead
    private _var = missionNamespace getVariable [_value, nil];
    if (!isNil "_var") exitWith {
        LOG("(parseValueType) Value parsed to VARIABLE (impicit).");
        (_var)
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

private _fnc_linkRefValue = {
    /* Checks that given key-value is a reference and links it to the actual value.
    _node - (HashMap or Array) container of the key
    _key - (Any) HashMap's key or Array's index
    _value - (Any) key's/index value
    _recursiveStack - (Array) stack of references during recursive reference resolve (e.g. key is referencing to another reference)
    Return: nothing
    */
    params ["_node", "_key", "_value", ["_recursiveStack", []]];
    LOG_1("(fnc_linkRefValue) Params: %1", _this);

    if (count _recursiveStack >= RECURSIVE_COUNTER_LIMIT) exitWith {
        LOG("(fnc_linkRefValue) [ERROR:ERR_DATA_RECURSIVE_REFERENCE] Too many recursive calls for given reference!");
        REPORT_ERROR_NOLINE_2(ERR_DATA_RECURSIVE_REFERENCE, "Too many recursive calls for given reference!", _key, _recursiveStack)
    };

    // Refs are always strings started with *
    if (typename _value != "STRING" || { !IS_REF_VALUE(_value) }) exitWith {
        LOG("(fnc_linkRefValue) Not a reference. Exit.");
        continue
    };
    LOG("(fnc_linkRefValue) Value is a reference! Check for value on given reference");

    // Search for referenced key
    private _pair = format ["%1: %2", _key, _value];
    private _refPath = ((_value select [1, count _value]) splitString toString [REF_INFIX]) apply { [_x] call CBA_fnc_trim};
    private _refValue = _hash;
    LOG_1("(fnc_linkRefValue) Reference path: %1", _refPath);
    {
        private _nodeType = typename _refValue;
        LOG_2("(fnc_linkRefValue) -- Key: %1 for %2 node", _x, _nodeType);
        if (_nodeType == "ARRAY") then {
            if (_x regexMatch INTEGER_REGEX) then {
                // Key is a number (array index)
                LOG("(fnc_linkRefValue) -- > Next step is Array index");
                _refValue = _refValue select parseNumber _x;
            } else {
                LOG("(fnc_linkRefValue) [ERROR:ERR_DATA_NAN_INDEX_REFERENECE] Wrong array index (non-integer)!");
                REPORT_ERROR_NOLINE_1(ERR_DATA_NAN_INDEX_REFERENECE,"Array index is not a number in Reference path", _pair);
                _refValue = nil;
            };
        } else {
            // Key is not a number (hashmap key)
            LOG("(fnc_linkRefValue) -- > Next step is HashMap key");
            _refValue = _refValue get _x;
        };

        if (isNil "_refValue") exitWith {
            LOG_1("(fnc_linkRefValue) -- ERROR -- Referenced to non-existing node [%1]", _x);
            REPORT_ERROR_NOLINE_2(ERR_DATA_NIL_REFERENCE, "Referencing to non-existing node!", _pair, _x);
        };

        LOG_2("(fnc_linkRefValue) -- >> %1 = %2", _x, _refValue);
    } forEach _refPath;

    if (isNil "_refValue") exitWith {};
    private _refType = typename _refValue;

    if (_refType == "STRING" && { IS_REF_VALUE(_refValue) }) exitWith {
        LOG_1("(fnc_linkRefValue) Ref value is another reference!. Value: %1", _refValue);
        _recursiveStack pushBack _value;
        [_node, _key, _refValue, _recursiveStack] call _fnc_linkRefValue;
    };
    LOG_2("(fnc_linkRefValue) Ref value found. Value: %1 (type: %2)", _refValue, _refType);

    // Set value
    if (_refType in ["ARRAY","HASHMAP"]) then {
        _node set [_key, +_refValue];
    } else {
        _node set [_key, _refValue];
    };
    LOG_2("(fnc_linkRefValue) Ref Linked! Key %1 = %2", _key, if (typename _node == "HASHMAP") then {_node get _key} else {_node select _key});
};

private _fnc_findRefValues = {
    /* Checks for containers in current node and links refereneces.
       _node - (HashMap or Array) container to check
       _key - (Any) HashMap's key or array index to check
       Return: nothing
    */
    params ["_node", "_key"];
    LOG_1("(fnc_findRefValues) Params: %1", _this);

    private _data = if (typename _node == "HASHMAP") then { _node get _key } else { _node select _key };
    private _type = typename _data;

    LOG_4("(fnc_findRefValues) Node type: %1. Key: %2. Data: %3 (type: %4)", typename _node, _key, _data, _type);

    switch _type do {
        case "HASHMAP": {
            LOG("(fnc_findRefValues) Value is HashMap. Invoke findAndLinkRefValues...");
            [_data] call _fnc_findAndLinkRefValues;
        };
        case "ARRAY": {
            // [1, {name: Kek}, *Radio > Kek]
            // 1 -> default root / link
            // {name: Kek} -> findAndLinkRefValues -> [Name] findRefValues -> defaul/link
            // *Radio > Kek -> default root / link
            LOG("(fnc_findRefValues) Value is Array. Invoke findRefValues for each array item...");
            {
                [_data, _forEachIndex] call _fnc_findRefValues;
            } forEach _data;
        };
        default {
            LOG("(fnc_findRefValues) Value is meaningful. Invoke fnc_linkRefValue...");
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

    LOG_1("(findAndLinkRefValues) Params: %1", _this);
    {
        [_node, _x] call _fnc_findRefValues;
    } forEach (keys _node) - [ERRORS_NODE, SOURCE_NODE];
};

private _fnc_findAndConvertToArray = {
    params ["_node"];
    LOG_1("(fnc_findAndConvertToArray) Params: %1", _this);

    private _isArray = true;
    {
        private _key = _x;
        private _keyType = typename _key;
        private _val = _node get _key;
        private _valType = typename _val;
        LOG_4("(fnc_findAndConvertToArray) Key: %1 (type: %2). Value: %3 (type: %4)", _key, _keyType, _val, _valType);

        // For each nested hashmap - check and convert it into the array
        if (_valType == "HASHMAP") then {
            LOG("(fnc_findAndConvertToArray) Value is a hashMap -> check for nested array");
            private _isNestedArray = [_val] call _fnc_findAndConvertToArray;
            if (_isNestedArray) then {
                LOG("(fnc_findAndConvertToArray) Value is a nested array! Converting...");
                // Replace nested map with array
                private _arr = [];
                for "_i" from 0 to (count _val) - 1 do {
                    _arr pushBack (_val get _i);
                };
                _node set [_key, _arr];
            };
        };
        if (_keyType != "SCALAR") then { _isArray = false; };
    } forEach (keys _node) - [ERRORS_NODE, SOURCE_NODE];

    LOG_1("(fnc_findAndConvertToArray) Node checked. Is Array? %1", _isArray);

    (_isArray)
};

private _fnc_parseLine = {
    // params ["_line", "_chars", "_startsWith", "_expectedIndent", "_actualIndent"];
    switch _mode do {
        case MODE_ROOT: {
            if (_actualIndent != 0) exitWith {
                LOG_1("(ROOT) Error - unexpected indent: %1", _actualIndent);
                REPORT_ERROR(ERR_INDENT_UNEXPECTED_ROOT, _forEachIndex, "Unexpected indent on parsing root element")
            };

            private _parsed = [_line] call _fnc_parseKeyValuePair;
            if (_parsed isEqualTo []) exitWith {
                REPORT_ERROR(ERR_DATA_MALFORMED, _forEachIndex, "Unknown markup in line (not a key-value pair/section/array).")
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
            if (_actualIndent == 0) exitWith {
                LOG("(NESTED) End of the all nested objects");
                _hashNodesRoute = [];
                _mode = MODE_ROOT;
                call _fnc_parseLine;
            };

            if (_actualIndent % 2 > 0) exitWith {
                LOG_1("(NESTED) [ERROR:%1] Indent malformed (%2 is not a multiple of 2)", ERR_INDENT_MALFORMED, _actualIndent);
                REPORT_ERROR(ERR_INDENT_MALFORMED, _forEachIndex, "Indent malformed (not a multiple of 2)");
            };

            private _calculated = call _fnc_calculateExpectedIndent;
            LOG_1("(NESTED) Calcualted indent: %1", _calculated);
            private _indentDiff = _calculated - _actualIndent;
            LOG_1("(NESTED) Indent diff = %1", _indentDiff);

            private _closedCount = floor (_indentDiff / 4);
            if (_indentDiff < 0 || (_indentDiff > 0 && _closedCount == 0)) exitWith {
                LOG_3("(NESTED) [ERROR:%1] Unexpected indent for nested item (expected %2, but actual is %3) ", ERR_INDENT_UNEXPECTED_NESTED, _calculated, _actualIndent);
                REPORT_ERROR(ERR_INDENT_UNEXPECTED_NESTED, _forEachIndex, "Unexpected indent for nested item (expected " + str _calculated + ", but actual is " + str _actualIndent);
            };

            if (_indentDiff > 0) then {
                LOG_1("(NESTED) End of the current %1 nested object(s).", _closedCount);
                _hashNodesRoute deleteAt (count _hashNodesRoute - 1 * _closedCount);
            };

            /*
            private _indentClosed = floor ((_actualIndent - _expectedIndent) / 4);
            LOG_1("(NESTED) Closed indent: %1.", _indentClosed);
            if (_indentClosed > 1) exitwith {
                LOG_2("(NESTED) Error - unexpected indent: %1 expected, but %2 found. Switching to MODE_ROOT.", _expectedIndent, _actualIndent);
                REPORT_ERROR(ERR_INDENT_UNEXPECTED_NESTED, _forEachIndex, "Unexpected indent on parsing nested element");
                _hashNodesRoute = [];
                _mode = MODE_ROOT;
                call _fnc_parseLine;
            };

            if (_indentClosed != 0) then {
                LOG_1("(NESTED) End of the current nested object. Closing %1 sections.", _indentClosed);
                _hashNodesRoute deleteAt (count _hashNodesRoute - 1 * abs(_indentClosed));
            };
            */

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
                REPORT_ERROR(ERR_DATA_MALFORMED, _forEachIndex, "Unknown markup in nested line (not a key-value pair/section/array).");
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

if !(_lines findIf { _x != "" } > -1) exitWith {
    REPORT_ERROR_NOLINE(ERR_FILE_NO_CONTENT, 'File has no content (or commented)!');
    _hash
};

private _hashNodesRoute = [];
private _mode = MODE_ROOT;

{
    private _line = _x;
    private _chars = toArray _line;
    private _startsWith = _chars # 0;
    private _expectedIndent = 4 * ({ typename _x != "SCALAR" } count _hashNodesRoute);
    private _actualIndent = 0;
    for "_i" from 0 to (count _chars)-1 do {
        if (_chars # _i != ASCII_SPACE) exitWith { _actualIndent = _i; };
    };
    LOG_3("Line %1: %2 [Indents: %3]", _forEachIndex+1, _line, _actualIndent);

    if (([_line] call CBA_fnc_trim) isEqualTo "") then {
        LOG_1("Line %1: Is empty. Skipped.", _forEachIndex+1);
        continue
    };

    [] call _fnc_parseLine;
} forEach _lines;

// Trigger conversion to array for last nested array in the file
[_hash] call _fnc_findAndConvertToArray;

// Link reference values
[_hash] call _fnc_findAndLinkRefValues;


LOG("----------------------------------- FINISHED -----------------------------");
LOG_1("Hash: %1", _hash);

(_hash)
