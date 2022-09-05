/*
    [@Hash, @Path, @Value, @ForceAdd?] call dzn_fnc_setByPath;

    Sets given value to given path in hashmap/array.

    Function walks though given path of nested hashmaps or arrays and
    selects specific node/index on each step until reaches target key.
    Then sets given value to this key.

    Optionally adds new nodes and key if nodes from given path are missing in the hash/array.

    Path format rules:
        - Path's keys may be any data types (see https://community.bistudio.com/wiki/HashMapKey)
        - Each node should be separate element of the array (e.g. ['NODE_A', 'Key'])
        - Last element in path should be a hashmap's key or index of array's element
        - For nested hashmap use key name (e.g. ['NODE_A', 'NODE_B', 'Key'])
        - For nested array use index (e.g. ['NestedArray', 1])
        - When using @ForceAdd flag to add new key:
            - to add key to HashMap - use any HashMapKey data type as node name
            - to add element to Array - use integer as index or -1 to push back to the tail of the array
        - When using @ForceAdd flag to add new nodes in the middle:
            - to add HashMap node to hashmap node - use any HashMapKey data type as node name (e.g. ["NodeA", "NodeB" <!>])
            - to add Array node to hashmap node   - use key name as string with `[]` in the tail of the node
                                                    name (e.g. ["NodeA", "NodeArray[] <!>, 1]")
            - to add HashMap node to array node   - use any HashMapKey data type as node name
                                                    (e.g. ["NodeArray", 1, "NestedNode" <!>, "Key"])
            - to add Array node to array node     - use `index[]` syntax (e.g. ["NodeArray", "2[]" <!>, -1]) to add
                                                    array into specific position.
                                                    Or use `[]` syntax to add array in the end (push back,
                                                    e.g. ["NodeArray", "[]" <!>, -1])

    EXAMPLE:
    [_hash, ["NodeA", "NodeB", "Key1"], 35] call dzn_fnc_setByPath; // Sets Key1 = 35
    [_hash, ["NestedArray", 1], 15] call dzn_fnc_setByPath; // Sets 15 to 1st element of the nested array of the hashmap

    _result = [_hash, ['NodeA', 'NodeB', 'Key99'], "New value!"] call dzn_fnc_setByPath; // _result = false, as 'Key99' doesn't exists
    _result = [_hash, ['NodeA', 'NodeB', 'Key99'], "New value!", true] call dzn_fnc_setByPath; // _result = true, adds Key99 = "Nee value!" to nested NodeB

    _result = [_hash, ["NodeA", "Nested[]", -1], 333, true] call dzn_fnc_setByPath; // true
    // In this example _hash has NodeA key, with hashmap in it. But NodeA doesn't contain "Nested" key.
    // Functinon adds a new array to HashMap "NodeA" under key "Nested", and then sets it's first element to 333

    INPUT:
        0: HashMap or Array - Structure to update
        1: Array            - Path to target key as array (e.g. ["Node", "Key"])
        2: Any              - Value to set
        3: Boolean          - (optional) On True - will add Key/Index if it is missing in the given structure. Default is false.
        4: Boolean          - (optional) On True - will add all path nodes if any of it is missing in the given structure.
                              Default is false.

    OUTPUT: Boolean - operation result (true - on success, false - on fail);
*/

//#define DEBUG true
#ifdef DEBUG
    #define LOG_PREFIX '[dzn_fnc_setByPath] '
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

params ["_hash", "_path", "_value", ["_forceAdd", false]];

LOG_1("Params: %1", _this);

private _nodes = _path;
LOG_1("Path: %1", str(_nodes));


private _curNode = _hash;
private _nodesSize = count _nodes - 1;
private _result = true;

private _fnc_addNode = {
    // Adds node in the middle to given structure
    params ["_node", "_key", "_addAsHashMap"];

    LOG_1("(fnc_addNode) Params: %1", _this);

    private "_newNode";
    if (_addAsHashMap) then {
        // Case: "NodeA" (current) > "NodeB" (missing) > "Val" [_key = "NodeB"]
        // Case: "NodeArr[]" > 2[] (current) > 3 (missing) > "Val" [_key = 3]
        LOG("(fnc_addNode) New node is a HashMap");
         _newNode = createHashMap;
    } else {
        // Case: "NodeA" (current) > "NestedArray[]" (missing) > 2 [_key = "NestedArray"]
        // Case: "NodeArr" (current) > "2[]" (missing) > 0 [_key = 2]
        // Case: "NodeArr" > "2[]" (current) > "1[]" (missing) > 0 [_key = 1]
        LOG("(fnc_addNode) New node is an Array");
        _newNode = [];
    };
    _node set [_key, _newNode];

    LOG_1("(fnc_addNode) Node after: %1", _node);

    (_newNode)
};

{
    LOG_1("---- %1 -----", _forEachIndex);
    LOG_1("Current Node: %1", _curNode);
    private _key = _x;
    LOG_1("Key: %1", _key);

    private _asHashMap = true;

    if (typename _key == "STRING" && { _key select [count _key - 2, 2] == "[]" }) then {
        _asHashMap = false;
        _key = _key select [0, count _key - 2];
        LOG_1("Key is array-marked. Stripped key: [%1]", _key);
        if (count _key == 0) then {
            _key = count _curNode;
            LOG_1("Key is zero-length (pushBack). Assigning calculated index of %1", _key);
        } else {
            // Check if key is all numbers (array index)
            if ({ _x >= 48 && _x <= 57 } count toArray _key == count toArray _key) then {
                LOG("Key is all-numbers (array index)");
                // Parse index number if key is in format: '2[]' (index + array hint)
                _key = parseNumber _key;
            };
        };
    };

    LOG_1("Key is array-marked? %1", !_asHashMap);
    LOG_1("Key type: %1", typename _key);

    if (isNil "_curNode") exitWith {
        _result = false;
        LOG("(ERROR) Node is not defined (nil)!");
    };

    switch (typename _curNode) do {
        case "HASHMAP": {
            LOG("Currnet node is a HashMap");
            if (_forEachIndex == _nodesSize) then {
                // Last node: set value
                if (_key in keys _curNode || _forceAdd) then {
                    _curNode set [_key, _value];
                    LOG("[HashMap.onEnd] Set value on the last node");
                } else {
                    _result = false;
                    LOG("[HashMap.onEnd] (ERROR) Failed to find a key.");
                };
            } else {
                // Node in the middle:
                // if key exists - switch to node in key
                // otherwise - if _forceAdd - add missing nodes, or return false
                LOG_1("[HashMap] Is key valid? %1", _key in keys _curNode);
                if (_key in keys _curNode) then {
                    _curNode = _curNode get _key;
                    LOG_1("[HashMap] New node found. Switching to node", _key);
                } else {
                    if (_forceAdd) then {
                        _curNode = [_curNode, _key, _asHashMap] call _fnc_addNode;
                        LOG_1("[HashMap] Created new node with name [%1]. Switching to new node", _key);
                    } else {
                        _result = false;
                        LOG_1("[HashMap] (ERROR) There is no node with name [%1]. Exiting...", _key);
                        break;
                    };
                };
            };
        };
        case "ARRAY": {
            private _isInRange = _key >= 0 && _key < count _curNode;
            LOG_1("Current node is an Array. Key in range?: %1", _isInRange);

            if (_forEachIndex == _nodesSize) then {
                // Last node:
                // if index is in range - return element
                // otherwise - return default.
                if (_isInRange) then {
                    _curNode set [_key, _value];
                    LOG_2("[Array.onEnd] New value set at %1 index = %2", _key, _value);
                } else {
                    if (_forceAdd) then {
                        if (_key < 0) then {
                            _curNode pushBack _value;
                            LOG("[Array.onEnd] Pushing back value as a new element of the array!");
                        } else {
                            _curNode set [_key, _value];
                            LOG_1("[Array.onEnd] Adding value as new element with index %1 to the array", _key);
                        };
                    } else {
                        _result = false;
                        LOG_1("[Array.onEnd] (ERROR) Given index [%1] is out of range", _key);
                    };
                };
            } else {
                // Array in the middle:
                // if index is in range - switch to node in element
                // otherwise - if _forceAdd - add new node, or exit with false

                LOG("[Array] Middle node...");
                if (_isInRange) then {
                    _curNode = _curNode select _key;
                    LOG("[Array] Switching to next node");
                } else {
                    if (_forceAdd) then {
                        _curNode = [_curNode, _key, _asHashMap] call _fnc_addNode;
                        LOG("[Array] Force created new node. Switching to it");
                    } else {
                        _result = false;
                        LOG_1("[Array] (ERROR) There is no element with index [%1]. Exiting...", _key);
                        break;
                    };
                };
            };
        };
        default {
            // Node appeared to be not an array/hash, but map's key
            // -> break loop and return false
            _result = false;
            LOG_2("[UNKNOWN] (ERROR) Current Node is not array/hashmap. Exiting...", _key);
            break;
        };
    };
} forEach _nodes;

LOG_1("Result: %1", _result);

_result
