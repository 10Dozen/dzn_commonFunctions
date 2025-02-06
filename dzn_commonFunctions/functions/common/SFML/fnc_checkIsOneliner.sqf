#include "defines.h"

/*
	Checks value to be a onliner structure (array, hashmap, expression or code)

	Params:
	0: _value (STRING) - potential oneliner

	Returns:
	_isOneliner - (BOOL)  true if value is oneliner, false otherwise.
*/


params ["_value"];
DBG_1("(checkIsOneliner) Params: %1", _this);

if (_value isEqualTo "") exitWith { "STRING" };

private _asChars = toArray _value;
private _first = _asChars select 0;
private _last = _asChars select (count _asChars - 1);
private _sameChars = _first == _last;
DBG_3("(checkIsOneliner) Value: %1. First: %2. Last: %3", _value, toString [_first], toString [_last]);

// Quoted STRING case - unwrap quotes and return: "My string"
(_sameChars && _first in STRING_QUOTES_ASCII)
// Expression case: `date select 2`
|| (_sameChars && _first == EXPRESSION_PERFIX_ASCII)
// Code case: { hint "Kek" }
|| (_first == CODE_PREFIX && _last == CODE_POSTIFX)
// Array case: [item1, item2]
|| (_first == ARRAY_PREFIX && _last == ARRAY_POSTFIX)
// HashMap case: (john: Doe, age: 33)
|| (_first == HASHMAP_PREFIX && _last == HASHMAP_POSTFIX)
