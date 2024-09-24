#include "defines.h"

/*
    Resets state of the Component object for Display.

    Params:
        0: _display (Display) - parent display to clear controls.

    Returns:
        nothing
*/

params ["_display"];

private _controls = _self get Q(Controls) get str(_display);
private _taggedControls = _self get Q(TaggedControls) get str(_display);

private ["_ctrl"];
{
    _ctrl = _taggedControls get _x;
    [_self, _ctrl] call (_self get Q(Removers) get (_ctrl getVariable P_TYPE));
    _taggedControls deleteAt _x;
} forEach (keys _taggedControls);
_controls resize 0;

true