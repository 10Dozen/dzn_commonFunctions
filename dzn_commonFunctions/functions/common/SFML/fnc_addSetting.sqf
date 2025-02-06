#include "defines.h"

/*
    Adds Key-Value pair to current active node

    Params:
    0: _key (STRING) - key to save value at.
	1: _value (STRING) - value to parse.
	2: _parseType (BOOL) - flag to parse value into SQF data type.

    Returns:
    nothing
*/

params ["_key", "_value", ["_parseType", true]];
private _node = _self call [F(getNode), []];
DBG_3("(addSettings) Adding: %1 = %2 to node %3", _key, _value, CURRENT_NODE_KEY);

private _parsedValue = if (_parseType) then { _self call [F(parseValueType), [_value]] } else { _value };
_node set [_key, [_parseValue, nil] select (isNil "_parsedValue")];