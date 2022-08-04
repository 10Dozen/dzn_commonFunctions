/*
 * [@Filename] call dzn_fnc_parseSettingsFile
 * Parses YAML-like settinsg file to HashMap..
 *
 * INPUT:
 * 0: STRING - path to file to parse
 *
 * OUTPUT:
 * 0: HASHMAP - map of the parsed settings. Errors will be available under 'ERRORS' key of the map.
 *
 * EXAMPLES:
 *      ["dzn_tSFramework\Modules\Chatter\Settings.yaml"] call dzn_fnc_parseSettingsFile
 */

#define DEBUG true
#ifdef DEBUG
    #define LOG_PREFIX '[dzn_fnc_parseSettingsFile] PARSER: '
    #define LOG(MSG) diag_log parseText (LOG_PREFIX + MSG)
    #define LOG_1(MSG,ARG1) diag_log parseText format [LOG_PREFIX + MSG,ARG1]
    #define LOG_2(MSG,ARG1,ARG2) diag_log parseText format [LOG_PREFIX + MSG,ARG1,ARG2]
    #define LOG_3(MSG,ARG1,ARG2,ARG3) diag_log parseText format [LOG_PREFIX + MSG,ARG1,ARG2,ARG3]
    #define LOG_4(MSG,ARG1,ARG2,ARG3,ARG4) diag_log parseText format [LOG_PREFIX + MSG,ARG1,ARG2,ARG3,ARG4]
#endif

#define ASCII_MINUS 45
#define ASCII_HASH 35
#define ASCII_BACKSLASH 92
#define ASCII_SPACE 32

#define MODE_ROOT 0
#define MODE_NESTED 10

#define CURRENT_NODE_KEY (if (count _hashNodesRoute > 0) then {_hashNodesRoute select (count _hashNodesRoute - 1)} else {""})

params ["_file"];

private _data = loadFile _file;
private _hash = createHashMap;
_hash set ["ERRORS", []];

if (count _data == 0) exitWith {
    diag_log text format ["[dzn_fnc_parseSettingsFile] Warning! File %1 is empty!", _file];
    (_hash get "ERRORS") pushBack [-1, '', 'File is empty!'];
    _hash
};
private _lines = _data splitString endl;
private _hashNodesRoute = [];
private _mode = MODE_ROOT;

forceUnicode 1;

private _fnc_removeComment = {
    private _lineChars = toArray _this;
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

private _fnc_parseKeyValuePair = {
    params ["_line"];
    if !(":" in _line) exitWith {
        LOG("-----------# No key definition found, this is not an key-value pair");
        []
    };
    private _parts = _line splitString ":";
    private _key = [_parts # 0] call CBA_fnc_trim;
    _parts deleteAt 0;
    private _value = [_parts joinString ":"] call CBA_fnc_trim;
    LOG_3("-----------# #PARSED# Key: %2, Value: %3", _forEachIndex, _key, _value);
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

private _fnc_addSetting = {
    params ["_key", "_value"];
    private _node = [] call _fnc_getNode;
    LOG_3("(addSettings) Adding: %1 = %2 to node %3", _key, _value, CURRENT_NODE_KEY);
    _node set [_key, _value];
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
    _map set [_key, values _subMap];
};

private _fnc_parseLine = {
    // params ["_line", "_chars", "_startsWith", "_expectedIndent", "_actualIndent"];
    switch _mode do {
        case MODE_ROOT: {
            if (_actualIndent != 0) exitWith {
                LOG_1("(ROOT) Error - unexpected indent: %1", _actualIndent);
                (_hash get "ERRORS") pushBack [_forEachIndex, _line, "Unexpected indent on parsing root element"];
            };
            if (_line isEqualTo "") exitWith {
                LOG("(ROOT) Line is a comment or empty");
            };

            private _parsed = [_line] call _fnc_parseKeyValuePair;
            if (_parsed isEqualTo []) exitWith {};
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
            private _indentClosed = floor ((_actualIndent - _expectedIndent) / 4);
            LOG_1("(NESTED) Closed indent: %1.", _indentClosed);
            if (_indentClosed > 1) exitwith {
                LOG_2("(NESTED) Error - unexpected indent: %1 expected, but %2 found. Switching to MODE_ROOT.", _expectedIndent, _actualIndent);
                (_hash get "ERRORS") pushBack [_forEachIndex, _line, "Unexpected indent on parsing nested element"];
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
                    private _arrayKey = [_line] call _fnc_addArrayItem;
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
    _line = _x call _fnc_removeComment;
    if ([_line] call CBA_fnc_trim isEqualTo "") then {
        LOG_1("Line %1: Is empty. Skipped.", _forEachIndex+1);
        continue
    };
    _chars = toArray _line;
    private _startsWith = _chars # 0;

    call _fnc_parseLine;
} forEach _lines;

[] call _fnc_convertToArray;



LOG("----------------------------------- FINISHED -----------------------------");
LOG_1("Hash: %1", _hash);

_hash
