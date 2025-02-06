#include "defines.h"

/*
    !!!TBD!!! 
	Finds and convert array nodes to actual arrays.

    Params:
	0:  () - 

    Returns:
    nothing
*/
params ["_currentNode", "_arrayNodes"];

{
    private _val = [_hash, _x] call dzn_fnc_getByPath;
    DBG_2("(fnc_findAndConvertToArray) Path: %1. Value: %2", _x, _val);

    private _arr = [];
    for "_i" from 0 to (count _val)-1 do {
        _arr set [_i, (_val get _i)];
    };

    [_hash, _x, _arr] call dzn_fnc_setByPath;

    DBG_2("(fnc_findAndConvertToArray) Converted: %1. Value: %2", [_hash, _x] call dzn_fnc_getByPath);
} forEach _arrayNodes;