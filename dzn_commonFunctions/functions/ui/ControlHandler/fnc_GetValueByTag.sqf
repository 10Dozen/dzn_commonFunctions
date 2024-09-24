#include "defines.h"

/*
    Returns tagged input value by given tag.

    Params:
        _display (Display) - parent display.
        _tag (String) - tagname of the control. "" means ALL controls.
        _exactMatch (bool) - optional, flag to find by exact match. Defaults to true.
    Returns:
        _values (Hashmap) - current values of filtered items or NIL if no controls found.
*/

params ["_display", ["_tag", ""], ["_exactMatch", true]];
LOG_ "[GetValueByTag] Params: %1", _this EOL;

private _values = (_self call [F(GetByTag), _this]) apply {
    [_x getVariable P_TAG, _self call [F(getControlValue), _x]]
};
if (_controls isEqualTo []) exitWith { nil };

createHashMapFromArray _values