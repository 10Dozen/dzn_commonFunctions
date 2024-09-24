#include "defines.h"
/*
    Merges hashmap with another hash map or key-value array.

    Params:
        0: _hash (HashMap) - hash map to merge into.
        1: _attrs (HashMap or Array) - attributes to add into _hash.

    Returns:
        nothing
*/

params ["_hash", "_attrs"];

if (typename _attrs == "ARRAY") exitWith {
    {
        _x params ["_key", "_value"];
        _hash set [toLowerANSI _key, _value];
    } forEach _attrs;
};

{
    _hash set [toLowerANSI _x, _y];
} forEach _attrs;
