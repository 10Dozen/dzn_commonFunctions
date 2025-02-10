#include "defines.h"

/*
    Parses line data into key and value by ":" char.

    Params:
    0: _lineChars (ARRAY of chars) - chars to parse.

    Returns:
    0: _key (STRING) - key name
    1: _value (ARRAY of chars) -  value

    One of the results may be returned:
    [] -- line doesn't contain ":" char
    [_key, ""] -- line contain only key (start of the nested section)
    [_key, _value] -- line is key-value pair
*/

params ["_lineChars"];

private _idx = _lineChars find ASCII_COLON;
if (_idx == -1) exitWith {
    DBG("(parseKeyValuePair) -----------# No key definition found, this is not an key-value pair");
    []
};

private _key = _lineChars select [0, _idx];
private _value = _lineChars select [idx+1, count _lineChars];

TRIM(_key,42);
TRIM(_value,42);

DBG_2("(parseKeyValuePair) -----------# #PARSED# Key: %1, Value: %2", toString _key, toString _value);

[toString _key, _value]

/*
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
*/