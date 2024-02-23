#include "defines.h"

/*
    Registers Parser and Renderer functions for specific control type passed
    in dzn_fnc_ShowAdvDialog2 function parameters.

    Params:
    0: _typeNames (ARRAY or STRING) - name of the control or list of names.
    1: _parseFunction (CODE) - code to parse control descriptors.
        Where _this:
        0: _item (HashMap) - hash map that stores parsed item data;
        1: _itemDescriptor (ARRAY) - list of item descriptors passed to dzn_fnc_ShowAdvDialog2.
        2: _idx (Number) - index of element in the list of item descriptors.
        Returns: nothing (_item is passed by reference and should be modified by function)

    2: _renderFunction (CODE) - code to render control.
        Where _this:
        0: _item (HashMap) - collection of parsed item attributes;
        1: _xOffset (Number) - calculated X position of item (regarding to dialog);
        2: _yOffset (Number) - calculated Y position of item (regarding to dialog);
        3: _itemWidth (Number) - calculated Width of the control;
        4: _itemHeight (Number) - calculated Height of the control;
        5: _dialog (Dialog) - parent dialog;
        6: _ctrlGroup (Control) - parent dialog's control group (items created within control group may be focused via keyboard Tab/arrow keys)
        Returns: _ctrl (created control that should be tracked by dialog)

    Return:
        nothing
*/

params ["_typeNames", "_parseFunction", "_renderFunction"];
if (typename _typeNames == "STRING") then {
    _typeNames = [_typeNames];
};
{
    private _name = toUpperANSI _x;
    (_self get Q(Parsers)) set [_name, _parseFunction];
    (_self get Q(Renderers)) set [_name, _renderFunction];
} forEach _typeNames;
