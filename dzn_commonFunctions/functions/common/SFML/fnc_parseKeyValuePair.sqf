#include "defines.h"

/*
	Parses line data into key and value by ":" char.

	Params:
	0: _line (STRING) - text to parse.

	Returns:
	0: _key (STRING) - key name
	1: _value (ANY) - parsed value

	One of the results may be returned:
    [] -- line doesn't contain ":" char
    [_key, ""] -- line contain only key (start of the nested section)
    [_key, _value] -- line is key-value pair
*/

params ["_line"];

private _chars = toArray _line;
private _idx = _chars findIf { _x == ASCII_COLON };
if (_idx == -1) exitWith {
    DBG("(parseKeyValuePair) -----------# No key definition found, this is not an key-value pair");
    []
};

private _result = [
	trim toString (_chars select [0, _idx]),
	trim toString (_chars select [idx+1, count _chars])
];
DBG_2("(parseKeyValuePair) -----------# #PARSED# Key: %1, Value: %2", _result select 0, _result select 1);

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