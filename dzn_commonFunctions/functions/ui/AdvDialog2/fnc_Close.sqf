#include "defines.h"
/*
    Closes dialog and unsetting all CBA events in the same frame.

    Params:
        none

    Returns:
        nothing
*/

{
    _x params ["_eventName", "", "", "_eventId"];
    diag_log format ["[CLOSE] Deleting event (on reset): %1 - id: %2", _eventName, _eventId];
    [_eventName, _eventId] call CBA_fnc_removeEventHandler;
} forEach (_self get Q(CBAEvents));

closeDialog 2;
