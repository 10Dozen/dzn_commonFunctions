#include "defines.h"

/*
    Returns list of the input's current values in the same order as inputs
    appeared in initial params.

    Params:
        none
    Returns:
        _values (Array) - array of various data, depending on input type:
            INPUT:    inputText(String)
            CHECKBOX: isChecked(Bool)
            SLIDER:   [currentPosition(Number), [minRange(Number), maxRange(Number)]]
            DROPDOWN/LISTBOX:
                      [selectedIndex(Number), selectedItemText(String), selectedItemValue(Anything)

*/

LOG_ "[GetValues] Invoked" EOL;
private _dialog = _self get Q(Dialog);

if (isNil "_dialog" || isNull _dialog) exitWith {
    LOG_ "[GetValues] No dialog found" EOL;
};

(_dialog getVariable Q(Inputs)) apply {
    _self call [F(getControlValue), _x]
}
