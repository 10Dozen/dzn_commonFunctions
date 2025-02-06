#include "defines.h"

/*
    Checks for containers in current node and links refereneces.

    Params:
	0: _node (HashMap or Array) - container to check
	1: _key (STRING or INDEX) - HashMap's key or array index to check

    Returns:
    nothing
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
        _self call [F(findAndLinkRefValues), [_data]];
    };
    case "ARRAY": {
        DBG("(fnc_findRefValues) Value is Array. Invoke findRefValues for each array item...");
        {
            _self call [F(findRefValues), [_data, _forEachIndex]];
        } forEach _data;
    };
    default {
        DBG("(fnc_findRefValues) Value is meaningful. Invoke fnc_linkRefValue...");
        _self call [F(linkRefValue), [_node, _key, _data]];
    };
};
