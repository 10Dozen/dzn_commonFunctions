/*
    Return value from given path in hashmap.
    Function walks through given path of nested hashmaps or arrays and
    selects specific node/index on each step until reaches target key.
    Then return it's value or defaults if misssing.

    Optionally return given default if there is no value found under the last key (or given array index is out of range).
    Optionally return given default if some node in path is missing (or given array index is out of range).

    Path (string) format rules:
    - All path's keys should be STRINGS or SCALAR!
    - Each node should be separated by ' > ' symbols (e.g. 'NODE_A > Key')
    - For nested hashmap use key name (e.g. 'NODE_A > NODE_B > Key')
    - For nested array use index (e.g. 'NestedArray > 1')
    - If node name is '>' or string of numbers ("1337") - use quotes (e.g. 'NODE_A > ">" > "1337"')

    Path (array) format rules:
    - Path's keys may be any data types (see https://community.bistudio.com/wiki/HashMapKey)
    - Each node should be separate element of the array (e.g. ['NODE_A', 'Key'])
    - For nested hashmap use key name (e.g. ['NODE_A', 'NODE_B', 'Key'])
    - For nested array use index (e.g. ['NestedArray', 1])
    - For scalar (numeric) hashmap keys use numbers as is (e.g. ['NODE_A', 1337])

    EXAMPLE:
    [_hash, "NodeA > NodeB > Key1", 10] call dzn_fnc_getPosOnGivenDir
    INPUT:
        0: HashMap or Array - HashMap to search
        1: String
           or Array         - Path to key as string (e.g. 'Node > Key') or array (e.g. ["Node", "Key"])
        2: Any              - (optional) Default value of target key, if missing
        3: Any              - (optional) Default value to return, if path is incorrect (e.g. some nodes are missing)

    OUTPUT:	Any (value of the key)
*/

#include "ascii_codes.hpp"

//#define DEBUG true
#ifdef DEBUG
    #define LOG_PREFIX '[dzn_fnc_getByPath] '
    #define LOG(MSG) diag_log text (LOG_PREFIX + MSG)
    #define LOG_1(MSG,ARG1) diag_log text format [LOG_PREFIX + MSG,ARG1]
    #define LOG_2(MSG,ARG1,ARG2) diag_log text format [LOG_PREFIX + MSG,ARG1,ARG2]
    #define LOG_3(MSG,ARG1,ARG2,ARG3) diag_log text format [LOG_PREFIX + MSG,ARG1,ARG2,ARG3]
    #define LOG_4(MSG,ARG1,ARG2,ARG3,ARG4) diag_log text format [LOG_PREFIX + MSG,ARG1,ARG2,ARG3,ARG4]
#else
    #define LOG_PREFIX
    #define LOG(MSG)
    #define LOG_1(MSG,ARG1)
    #define LOG_2(MSG,ARG1,ARG2)
    #define LOG_3(MSG,ARG1,ARG2,ARG3)
    #define LOG_4(MSG,ARG1,ARG2,ARG3,ARG4)
#endif

params ["_hash", "_path", "_defaultValue", "_defaultOnMissingValue"];

LOG_1("Params: %1", _this);
LOG_1("DefaultValue defined? %1", !isNil "_defaultValue");
LOG_1("DefaultOnMissingValue defined? %1", !isNil "_defaultOnMissingValue");

private _nodes = [];
if (typename _path == "STRING") then {
    LOG_1("[PathAsString]: %1", _path);

    // Parse string Path into array
    private _delimeter = [ASCII_SPACE, ASCII_GT, ASCII_SPACE];
    private _chars = (toArray _path) + _delimeter;
    private _nodeChars = [];

    for "_i" from 0 to (count _chars - 3) do {
        private _char = _chars # _i;
        private _triplet = _chars select [_i, 3];

        LOG_2("[PathAsString] %1 : Triplet: %2", _i, toString _triplet);

        if (_triplet isEqualTo _delimeter) then {
            private _node = toString _nodeChars;
            private _first = _nodeChars select 0;
            private _last = _nodeChars select (count _nodeChars - 1);

            LOG_2("[PathAsString] %1 : Delimeter found. Node: %2", _i, _node);

            // Extract from quotes ('>' or '1337' case)
            if (_first == _last && _first in [ASCII_QUOTE, ASCII_DOUBLE_QUOTE]) then {
                LOG("[PathAsString] Quotation detected");
                private _nested = toString (_nodeChars select [1, count _nodeChars - 2]);
                if (_nested isEqualTo toString [ASCII_GT]
                    || _nested isEqualTo str (parseNumber _nested)
                ) then {
                    LOG("[PathAsString] Nested is a '>' or numeric string. Exctracting.");
                    _node = _nested;
                };
            } else {
                LOG("[PathAsString] Checking for number");
                if (_node isEqualTo str (parseNumber _node)) then {
                    LOG("[PathAsString] Is a number!");
                    _node = parseNumber _node;
                };
            };

            if (_nested regexMatch "([\d\.\-e]*)") then {
                LOG("[PathAsString] Exctracted number");
                _node = parseNumber toString _nested;
            };

            LOG_1("[PathAsString] Saving node name [%1]", _node);

            _nodes pushBack _node;

            _i = _i + 2; // Skip delimeter chars
            _nodeChars resize 0;
        } else {
            _nodeChars pushBack _char;
            LOG_1("[PathAsString] Node chars: %1", toString _nodeChars);
        };
    };
} else {
    // Use array as path:
    LOG_1("[PathAsArray]: %1", str(_path));
    _nodes = _path;
};

LOG_1("Path: %1", str(_nodes));

private "_value";
private _curNode = _hash;
private _nodesSize = count _nodes - 1;
{
    private _key = _x;
    LOG_1("Key: %1", _key);

    switch (typename _curNode) do {
        case "HASHMAP": {
            LOG("Currnet node is a HashMap");
            if (_forEachIndex == _nodesSize) then {
                // Last node: return value or default
                _value = _curNode getOrDefault [_key, _defaultValue];
                LOG_1("[HashMap.onEnd] Get value on the last node = %1", _value);
            } else {
                // Node in the middle:
                // if key exists - switch to node in key
                // otherwise - return defaultOnMissing
                LOG_1("[HashMap] Is key valid? %1", _key in keys _curNode);
                if (_key in keys _curNode) then {
                    _curNode = _curNode get _key;
                    LOG_1("[HashMap] New node found. Switching to node", _key);
                } else {
                    _value = _defaultOnMissingValue;
                    LOG_2("[HashMap] (ERROR) There is no node with name [%1]. Exiting with default on missing value [%2]", _key, _value);
                    break;
                };
            };
        };
        case "ARRAY": {
            private _isInRange = _key < count _curNode;

            if (_forEachIndex == _nodesSize) then {
                // Last node:
                // if index is in range - return element
                // otherwise - return default.
                if (_isInRange) then {
                    _value = _curNode select _key;
                    LOG_2("[Array.onEnd] Return element at %1 index = %2", _key, _value);
                } else {
                    _value = _defaultValue;
                    LOG_2("[Array.onEnd] Index %1 is out of range. Return default value = %2", _key, _value);
                };
            } else {
                // Array in the middle:
                // if index is in range - switch to node in element
                // otherwise - return defaultOnMissing
                if (_isInRange) then {
                    _curNode = _curNode select _key;
                    LOG("[Array] Switching to next node");
                } else {
                    _value = _defaultOnMissingValue;
                    LOG_2("[HashMap] (ERROR) There is no element with index [%1]. Exiting with default on missing value [%2]", _key, _value);
                    break;
                };
            };
        };
        default {
            // Node appeared to be not an array/hash, but map's key
            // -> break loop and return fallback default
            _value = _defaultOnMissingValue;
            LOG_2("[UNKNOWN] (ERROR) Current Node is not array/hashmap. Exiting with default on missing value [%2]", _key, _value);
            break;
        };
    };
} forEach _nodes;

LOG_1("Result: %1", _value);

_value
