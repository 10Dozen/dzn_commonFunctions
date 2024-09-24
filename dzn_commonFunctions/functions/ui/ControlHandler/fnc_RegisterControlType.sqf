#include "defines.h"

/*
    Registers Parser and Renderer functions for specific control type passed
    in dzn_fnc_ShowAdvDialog2 function parameters.

    Params:
    0: _typeNames (ARRAY or STRING) - name of the control or list of names.
    1: _parseFunction (CODE) - code to parse control descriptors.
        Where _this:
        0: _componentObject (HashMapObject) - 
        1: _item (HashMap) - hash map that stores parsed item data;
        2: _itemDescriptor (ARRAY) - list of item descriptors passed to original function
        3: _idx (Number) - index of element in the list of item descriptors.
        Returns: nothing (_item is passed by reference and should be modified by function)

    2: _createFunction (CODE) - code to create control.
        Where _this:
        0: _componentObject (HashMapObject) - 
        1: _itemAttributes (HashMap) - parsed attributes of the element.
        2: _dialog (Display) - parent display.
        3: _ctrlGroup (Control) - optional, parent dialog's control group (items created within control group may be focused via keyboard Tab/arrow keys)
        Returns: _ctrl (created control)

    3: _renderFunction (CODE) - code to render control.
        Where _this:
        0: _componentObject (HashMapObject) - 
        1: _ctrl (Control) - control to apply attributes for proper render.
        2: _itemAttrs (HashMap) - attibutes of the control.
        Returns: _ctrl (created control)

    Return:
        nothing
*/

params ["_typeNames", "_parseFunction", "_createFunction", "_renderFunction", ["_removeFunction", { 
    params ["_cob", "_ctrl"];
    ctrlDelete _ctrl;
}]];

if (typename _typeNames == "STRING") then {
    _typeNames = [_typeNames];
};

{
    private _name = toUpperANSI _x;
    (_self get Q(Parsers)) set [_name, _parseFunction];
    (_self get Q(Creators)) set [_name, _createFunction];
    (_self get Q(Renderers)) set [_name, _renderFunction];
    (_self get Q(Removers)) set [_name, _removeFunction];
} forEach _typeNames;
