#include "defines.h"

/*
    Checks that given key-value is a reference and links it to the actual value.

    Params:
    0: _value (STRING) - value to parse.

    0: _node (HashMap or Array) - container of the key
    1: _key (STRING or NUMBER) - HashMap's key or Array's index
    2: _value (Any) - key's/index value
    3: _recursiveStack (Array) - stack of references during recursive reference resolution
    (e.g. key is referencing to another reference)

    Returns:
    nothing
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
    trim _x
};
private _refValue = _hash;
DBG_1("(fnc_linkRefValue) Reference path: %1", _refPath);
{
    if (_refValue isEqualType []) then {
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
    _self call ["linkRefValue", [_node, _key, _refValue, _recursiveStack]];
};
DBG_2("(fnc_linkRefValue) Ref value found. Value: %1 (type: %2)", _refValue, _refType);

// Set value
if (_refType in ["ARRAY","HASHMAP"]) then {
    _node set [_key, +_refValue];
} else {
    _node set [_key, _refValue];
};
DBG_2("(fnc_linkRefValue) Ref Linked! Key %1 = %2", _key, if (typename _node == "HASHMAP") then {_node get _key} else {_node select _key});
    