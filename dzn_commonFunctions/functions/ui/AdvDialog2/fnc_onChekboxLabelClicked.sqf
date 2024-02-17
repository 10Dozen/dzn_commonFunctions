#include "defines.h"

/*
    Handles click on checkbox related text and toggles checkbox.

    Params (see onMouseClick UI EH):
        0: _control (Control) - clicked control;
        1: _button (Number) - used button.

    Returns:
        nothing
*/

params ["_control", "_button", "", "", "", "", ""];

private _cb = _control getVariable Q(relatedCheckbox);
if (!ctrlEnabled _cb) exitWith {};
_cb cbSetChecked !(cbChecked _cb);
