#include "defines.h"

/*
    Handles slider change event for SLIDER item and updates Slider's tooltip with
    current selected value and available range.

    User-derined tooltip will be prepended.

    Params (see OnSliderChange UI EH):
        0: _ctrl (Control) - slider control.
        1: _newValue (Number) - current value of slider

    Returns:
        nothing
*/

params ["_ctrl", "_newValue"];


private _customTooltipText = _ctrl getVariable [Q(sliderCustomTooltip), ""];
if (_customTooltipText != "") then {
    _customTooltipText = _customTooltipText + "\n";
};
private _range = sliderRange _ctrl;

_ctrl ctrlSetTooltip format [
    "%1%2 (min: %3, max: %4)",
    _customTooltipText,
    _newValue, _range # 0, _range # 1
];
