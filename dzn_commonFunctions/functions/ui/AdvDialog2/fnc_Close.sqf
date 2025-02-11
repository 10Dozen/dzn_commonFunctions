#include "defines.h"
/*
    Closes dialog and unsetting all CBA events in the same frame.

    Params:
        none

    Returns:
        nothing
*/

params [["_interrupted", false]]
DBG("Invoked!");

_self set [Q(Closed), true];
["dzn_AdvDialog2_onClosed", [_self get Q(Dialog), _self get Q(DialogID), _self, _interrupted]] call CBA_fnc_localEvent;

private _dialog = _self get Q(Dialog);
{
    ctrlDelete _x;
} forEach (_dialog getVariable Q(AllDialogControls));

{
    _x params ["_eventName", "", "", "_eventId"];
    [_eventName, _eventId] call CBA_fnc_removeEventHandler;
} forEach (_self get Q(CBAEvents));

if (_dialog isNotEqualTo (findDisplay DIALOG_ID)) exitWith {
    _self set [Q(Dialog), displayNull];
    _self set [Q(DialogID), ""];
    DBG("Non-standalone dialog. Skip closeDialog, but clear dialog.");
};

closeDialog 2;
