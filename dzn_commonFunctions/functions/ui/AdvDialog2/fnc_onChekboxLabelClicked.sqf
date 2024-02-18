#include "defines.h"

/*
    Handles click on checkbox related text and toggles checkbox.

    Params (see onMouseClick UI EH):
        0: _control (Control) - clicked control;
        1: _button (Number) - used button.

    Returns:
        nothing
*/

params ["_cbLabelControl", "_button", "", "", "", "", ""];

private _cbControl = _cbLabelControl getVariable Q(relatedCheckbox);
if (!ctrlEnabled _cbControl) exitWith {};
_cbControl cbSetChecked !(cbChecked _cbControl);
