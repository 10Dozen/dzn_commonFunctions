#include "defines.h"

/*
    Returns current value of given control.

    Params:
        _control (Control) - control to get value from.

    Returns:
        _value (Anything) - value of the control, depeneding on it's type.
*/
DBG_1("Params: %1", _this);
DBG_1("Control type=%1", _this getVariable Q(type));

private _value = switch (_this getVariable Q(type)) do {
    case Q(INPUT);
    case Q(INPUT_AREA): { ctrlText _this };
    case Q(CHECKBOX);
    case Q(CHECKBOX_RIGHT): { cbChecked _this };
    case Q(SLIDER): { [sliderPosition _this, sliderRange _this] };
    case Q(LISTBOX);
    case Q(DROPDOWN): {
        private _selectedIndex = lbCurSel _this;
        // -- Prevent selecting value when cur sel is out of range
        if (_selectedIndex == -1 || _selectedIndex >= count (_this getVariable Q(listValues))) exitWith {
            [-1, nil, nil]
        };

        [
            _selectedIndex,
            _this lbText _selectedIndex,
            (_this getVariable Q(listValues)) # _selectedIndex
        ]
    };
};

DBG_1("Value=%1", _value);

_value
