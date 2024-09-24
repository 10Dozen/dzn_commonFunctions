#include "defines.h"

/*
    Returns current value of given control.

    Params:
        _control (Control) - control to get value from.

    Returns:
        _value (Anything) - value of the control, depeneding on it's type.
*/

LOG_ "[GetControlValue] _this=%1", _this EOL;
LOG_ "[GetControlValue] Control type=%1", _this getVariable Q(type) EOL;

private _value = switch (_this getVariable Q(type)) do {
    case Q(INPUT);
    case Q(INPUT_AREA): { ctrlText _this };
    case Q(CHECKBOX);
    case Q(CHECKBOX_RIGHT): { cbChecked _this };
    case Q(SLIDER): { [sliderPosition _this, sliderRange _this] };
    case Q(LISTBOX);
    case Q(DROPDOWN): {
        private _selectedIndex = lbCurSel _this;
        [
            _selectedIndex,
            _this lbText _selectedIndex,
            (_this getVariable Q(listValues)) # _selectedIndex
        ]
    };
};

LOG_ "[GetControlValue] Value=%1", _value EOL;

_value
