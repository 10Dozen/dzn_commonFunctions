#include "defines.h"

/*
    Parse setting value. Rules:
    - String --> quoted OR any text that not match rules below
    - Boolean --> value is equal to true/false AND not quoted
    - Scalar --> consists of only digit symbols or separators AND not quoted
    - Code --> first and last symbol are { } AND not quoted
    - Expression --> first and last symbols are ` AND not quoted
    - Array --> first and last symbols are [ ] AND not quoted
    - HashMap --> first and last symbols are ( ) AND not quoted
    - Variable --> first and last symbols are <> OR (missionNamespace has value AND not quoted)
    - Side --> value is one of the sides list AND not quoted
    - Reference --> first symbol is * AND not quoted
    - nil --> 'nil' value
    - null --> one of null types names (objNull, grpNull, locationNull)

    Params:
    0: _value (STRING) - value to parse.

    Returns:
    _result (ANY) - parsed value.
*/


params ["_value"];
DBG_1("(parseValueType) Params: %1", _this);

if (_value isEqualTo "") exitWith {
    DBG("(parseValueType) Value parsed to STRING (empty).");
    ""
};

private _asChars = toArray _value;
private _first = _asChars # 0;
private _last = _asChars select (count _asChars - 1);
private _sameChars = _first == _last;

DBG_3("(parseValueType) Value: %1. First: %2. Last: %3", _value, toString [_first], toString [_last]);

// Quoted STRING case - unwrap quotes and return: "My string"
if (_sameChars && _first in STRING_QUOTES_ASCII) exitWith {
    DBG("(parseValueType) Value parsed to STRING (explicit).");
    _value = _self call ["removeEscaping", [STRIP(_asChars)]];
    (_value)
};

// Boolean case: true
if (toLower _value in ['true', 'false']) exitWith {
    DBG("(parseValueType) Value parsed to BOOLEAN.");
    (call compile _value)
};

// Scalar case: 23.32 or equations
if (toLower _value regexMatch SCALAR_TYPE_REGEX) exitWith {
    DBG("(parseValueType) Value parsed to SCALAR.");
    (call compile _value)
};

// Code case: { hint "Kek" }
if (_first == CODE_PREFIX && _last == CODE_POSTIFX) exitWith {
    DBG("(parseValueType) Value parsed to CODE.");
    (compile STRIP(_value))
};

// Array case: [item1, item2]
if (_first == ARRAY_PREFIX && _last == ARRAY_POSTFIX) exitWith {
    DBG("(parseValueType) Value parsed to ONELINE ARRAY.");
    (_self call [F(parseOnelinerStructure), [_value, ONELINER_ARRAY]])
};

// HashMap case: (john: Doe, age: 33)
if (_first == HASHMAP_PREFIX && _last == HASHMAP_POSTFIX) exitWith {
    DBG("(parseValueType) Value parsed to ONELINE HASHMAP.");
    (_self call [F(parseOnelinerStructure), [_value, ONELINER_HASHMAP]])
};

// Explicit Variable case: <spearhead>
if (_first == VARIABLE_PREFIX && _last == VARIABLE_POSTFIX) exitWith {
    DBG("(parseValueType) Value parsed to VARIABLE (explicit).");
    private _var = missionNamespace getVariable [STRIP(_value), nil];
    if (isNil "_var") then {
        REPORT_ERROR_1(ERR_DATA_NIL_VARIABLE_REF, _forEachIndex, "Value is referencing to non-existing variable", STRIP(_value));
        nil
    } else {
        _var
    };
};

// Expression case: `date select 2`
if (_sameChars && _first == EXPRESSION_PERFIX_ASCII) exitWith {
    DBG("(parseValueType) Value parsed to EXPRESSION.");
    (_args call compile STRIP(_value))
};

// Reference values - skip processing, as it should be resolved to actual value later
if (_first == REF_PREFIX) exitWith {
    DBG("(parseValueType) Value parsed to REFERENCE.");
    _hasReferences = true;
    (format ["%1%2", REF_PREFIX_PROCESSED, _value select [1, count _value]])
};

// Side case: west
private _side = _self get Q(Sides) get _value;
if (!isNil "_side") exitWith {
    DBG("(parseValueType) Value parsed to SIDE.");
    _side
};

// Special data: nil
if (_value == NIL_TYPE) exitWith {
    DBG("(parseValueType) Value parsed to NIL.");
    nil
};

// Special data - null: objNull/grpNull
private _nullType = _self get Q(NullTypes) get _value;
if (!isNil "_nullType") exitWith {
    DBG("(parseValueType) Value parsed to NULL.");
    _nullType
};

// Otherwise - it's just a string without quoting
DBG("(parseValueType) Value parsed to STRING.");

_value = _self call [F(removeEscaping), [_asChars]];
(_value)