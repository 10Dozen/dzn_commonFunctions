#include "defines.h"

/*
    Adds Key-Value pair to current active node

    Params:
    0: _key (STRING) - key to save value at.
	1: _value (ARRAY of chars OR ANY) - value to parse or value to save, if _parseT_convertToTypeoType flag is false.
	2: _convertToType (BOOL) - flag to convert value into SQF data type.

    Returns:
    nothing
*/

params ["_key", "_value", ["_convertToType", true]];
private _node = _self call [F(getNode), []];
DBG_3("(addSettings) Adding: %1 = %2 to node %3", _key, toString _value, _node);

private _parsedValue = _value;
if (_convertToType) then { 
    _parsedValue = _self call [F(parseValueType), [_value]]
};

_node set [
    _key, 
    [_parsedValue, nil] select (isNil "_parsedValue")
];