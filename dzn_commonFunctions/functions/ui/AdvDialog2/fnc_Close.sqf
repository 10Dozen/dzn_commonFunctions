#include "defines.h"
/*
    Closes dialog and unsetting all CBA events in the same frame.

    Params:
        none

    Returns:
        nothing
*/

private _dialog = _self get Q(Dialog);
{
    ctrlDelete _x;
} forEach (_dialog getVariable Q(AllDialogControls));

{
    _x params ["_eventName", "", "", "_eventId"];
    [_eventName, _eventId] call CBA_fnc_removeEventHandler;
} forEach (_self get Q(CBAEvents));


if (_dialog isNotEqualTo (findDisplay DIALOG_ID)) exitWith {};

closeDialog 2; 
