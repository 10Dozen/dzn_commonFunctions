#include "defines.h"

/*
    Resets state of the Component object for Display.
    When running with no params - removes all controls in all displays.

    Params:
        0: _display (Display) - parent display to clear controls.

    Returns:
        nothing
*/

DBG_1("Params: %1", _display);
params ["_display"];

if (isNil "_display") exitWith {
    private _allDisplays = keys (_self get Q(Controls));
    DBG_1("Displays: %1", _allDisplays);

    {
        DBG_1("Removing controls of %1 display", _x);
        {
            private _ctrl = _x;
            [_self, _ctrl] call (_self get Q(Removers) get (_ctrl getVariable P_TYPE));
            DBG_2("Removing control %1 of type %2", _ctrl, _ctrl getVariable P_TYPE);
        } forEach (_self get Q(Controls) get _x);

        (_self get Q(TaggedControls)) set [_x, createHashMap];
        (_self get Q(Controls)) set [_x, []];
    } forEach _allDisplays;

    private _gameDisplayCtrls = uiNamespace getVariable [Q(dzn_ControlHandler_MainGameControls), []];

    DBG_1("Deleting main game display controls: %1", _gameDisplayCtrls);
    {
        DBG_1("Deleting main game display control: %1", _x);
        [_self, _x] call (_self get Q(Removers) get (_x getVariable P_TYPE));
    } forEach _gameDisplayCtrls;
    _gameDisplayCtrls resize 0;

    true
};


private _controls = _self get Q(Controls) get str(_display);
private _taggedControls = _self get Q(TaggedControls) get str(_display);

private ["_ctrl"];
{
    _ctrl = _taggedControls get _x;
    [_self, _ctrl] call (_self get Q(Removers) get (_ctrl getVariable P_TYPE));
    _taggedControls deleteAt _x;
} forEach (keys _taggedControls);
_controls resize 0;

if (_display isEqualTo (findDisplay 46)) then {
    private _gameDisplayCtrls = uiNamespace getVariable [Q(dzn_ControlHandler_MainGameControls), []];
    {
        [_self, _x] call (_self get Q(Removers) get (_x getVariable P_TYPE));
    } forEach _gameDisplayCtrls;
    _gameDisplayCtrls resize 0;
};

true