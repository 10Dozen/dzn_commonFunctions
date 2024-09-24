#include "defines.h"

/*
    Deletes control

    Params:
        _display - display or display
        _filterByTag - string tag to find control, none means delete all controls

    Returns:
        _success (BOOL) - true if control(s) was deleted, false - if not found
*/

params ["_display", ["_tag", ""]];

LOG_ "[RemoveControl] Params: %1", _this EOL;

// -- Handle delete all case
if (_tag == "") exitWith { _self call [F(reset), _display] };

// -- Find and delete by Tag
private _ctrls = _self call [F(GetByTag), [_display, _tag]];
LOG_ "[RemoveControl] Control found by tag (%2): %1", _ctrls, count _ctrls EOL;
if (_ctrls isEqualTo []) exitWith { false };

private _controls = _self get Q(Controls) get str(_display);
private _taggedControls = _self get Q(TaggedControls) get str(_display);
private ["_ctrl"];
{
    _ctrl = _x;
    _controls deleteAt (_controls findIf { _x isEqualTo _ctrl });
    _taggedControls deleteAt (_ctrl getVariable P_TAG);
    
    [_self, _ctrl] call (_self get Q(Removers) get (_ctrl getVariable P_TYPE));
} forEach _ctrls;

LOG_ "[RemoveControl] Controls tagged '%1' was deleted successfully from display %2", _tag, _display EOL;
true