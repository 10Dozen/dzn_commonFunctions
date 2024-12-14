#include "defines.h"

/*
    Handles slider change event for SLIDER item and updates Slider's tooltip with
    current selected value and available range.

    User-derined tooltip will be prepended.

    Params (see OnSliderChange UI EH):
        0: _sliderControl (Control) - slider control.
        1: _newValue (Number) - current value of slider

    Returns:
        nothing
*/

params ["_sliderControl", "_newValue"];

(_sliderControl getVariable P_ATTRS) set [A_VALUE, _newValue];

private _customTooltipText = _sliderControl getVariable [P_CUSTOM_TOOLTIP, ""];
if (_customTooltipText != "") then {
    _customTooltipText = _customTooltipText + "\n";
};
private _range = sliderRange _sliderControl;

_sliderControl ctrlSetTooltip format [
    "%1%2 (min: %3, max: %4)",
    _customTooltipText,
    _newValue, _range # 0, _range # 1
];
