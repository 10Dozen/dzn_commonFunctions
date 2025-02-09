#include "defines.h"

/*
    Modifies control

    Params:
        _display - display or dialog
        _tag - string tag to find control, none means delete all controls.
        _newSetOfAttribures (ARRAY) - list of attributes

    Returns:
        _control (Control) - modified control or nil
*/

params ["_display", ["_tag", ""], ["_newAttrs", []], ["_newEvents", []]];

DBG_1("Params: %1", _this);

private _controls = _self call [F(GetByTag), [_display, _tag]];
if (_controls isEqualTo []) exitWith {
    DBG_2("Failed to find controls with tag '%1' in display %2", _tag, _display);
    false
};

DBG_1("_controls=%1", _controls, _display);

{
    // -- Override current attributes
    private _attrs = _x getVariable [P_ATTRS, createHashMap];
    // -- Parse and merge
    [_self, _attrs, [_newAttrs, _newEvents], _x] call (_self get Q(Parsers) get (_x getVariable P_TYPE));

    DBG_1("On parsed=%1", _attrs);

    // -- If A_POS was redefined by modify - parse it to X,Y,W,H
    if (_newAttrs findIf { _x # 0 == A_POS } > -1) then {
        (_attrs get A_POS) params [
            ["_xPos", _attrs get A_X],
            ["_yPos", _attrs get A_Y],
            ["_w", _attrs get A_W],
            ["_h", _attrs get A_H]
        ];

        _attrs set [A_X, _xPos];
        _attrs set [A_Y, _yPos];
        _attrs set [A_W, _w];
        _attrs set [A_H, ((_attrs get A_SIZE) + LINE_HEIGHT_OFFSET) max _h];
    } else {
        _attrs set [A_H, ((_attrs get A_SIZE) + LINE_HEIGHT_OFFSET) max (_attrs get A_H)];
    };
    DBG_1("Modified attributes=%1", _attrs);

    // -- Call re-render
    _self call [F(render), [_display, _attrs, _x]];
    DBG("Rendered");
} forEach _controls;

DBG_2("Control(s) tagged '%1' was modified successfully in display %2", _tag, _display);

true