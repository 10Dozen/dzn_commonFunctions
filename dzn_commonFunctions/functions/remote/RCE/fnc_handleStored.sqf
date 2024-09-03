#include "defines.h"

/*
    Loops through stored remoteExec calls of the given Component 
    and execute calls to this component.

    (_self) 
    
    Params:
    _cobName (string) - name of the Component.

    Return: nothing

    Example:
    dzn_RCE call ["fnc_handleStored", ["tSF_Respawn"]]
*/
params ["_cobName"];

LOG_ "(HandleStored) Params: %1", _this EOL;

private _storedCalls = _self get Q(storedCalls) get (toLowerANSI _cobName);
if (isNil "_storedCalls") exitWith {};

{
    LOG_ "(HandleStored) Call %1: %2", _forEachIndex, _x  EOL;
    _self call [F(receive), _x];
} forEach _storedCalls;

// -- Clear stored calls list
_storedCalls resize 0;