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

LOG_ "[ModifyControl] Params: %1", _this EOL;

private _controls = _self call [F(GetByTag), [_display, _tag]];
if (_controls isEqualTo []) exitWith {
    LOG_ "[ModifyControl] Failed to find controls with tag '%1' in display %2", _tag, _display EOL;
    false
};

LOG_ "[ModifyControl] _controls=%1", _controls, _display EOL;

{
    // -- Override current attributes
    private _attrs = _x getVariable [P_ATTRS, createHashMap];
    // -- Parse and merge
    [_self, _attrs, [_newAttrs, _newEvents], _x] call (_self get Q(Parsers) get (_x getVariable P_TYPE));
    //_self call [F(MergeAttributes), [_attrs, _newAttrsMap]];

    
    LOG_ "[ModifyControl] On parsed=%1", _attrs EOL;
    private _newPos = _attrs get A_POS;
    private _newAttrsKeys = _newAttrs apply { _x # 0 };
    if (A_X in _newAttrsKeys || A_Y in _newAttrsKeys || A_W in _newAttrsKeys || A_H in _newAttrsKeys) then {
        _newPos = [
            _attrs get A_X,
            _attrs get A_Y,
            _attrs get A_W,
            _attrs get A_H
        ];
        _attrs set [A_POS, _newPos];
    };
    // -- Parse POS params and map to X,Y,W,H
    _newPos params ["_xPos", "_yPos", "_w", "_h"];
    _attrs set [A_X, _xPos];
    _attrs set [A_Y, _yPos];
    _attrs set [A_W, _w];
    _attrs set [A_H, ((_attrs get A_SIZE) + LINE_HEIGHT_OFFSET) max _h];
    LOG_ "[ModifyControl] Modified attributes=%1", _attrs EOL;

    // -- Call re-render
    _self call [F(render), [_display, _attrs, _x]];
    LOG_ "[ModifyControl] Rendered" EOL;
} forEach _controls;

LOG_ "[ModifyControl] Control(s) tagged '%1' was modified successfully in display %2", _tag, _display EOL;
true