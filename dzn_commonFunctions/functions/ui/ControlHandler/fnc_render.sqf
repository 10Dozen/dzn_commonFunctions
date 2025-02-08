#include "defines.h"

/*
    Renders COB.Items and shows dialog on screen.

    Params:
        nothing (refers to COB.Items and COB.LineHeights properties)
    Retunrs:
        nothing
*/

params ["_display", "_itemAttrs", ["_ctrl", controlNull]];
DBG_1("Params: %1", _this);

private _itemType = _itemAttrs get A_TYPE;
DBG_1("Rendering started for control type %1", _itemType);

if (isNull _ctrl) then {
    private _controls = _self get Q(Controls) getOrDefaultCall [str(_display), { [] }, true];
    private _taggedControls = _self get Q(TaggedControls) getOrDefaultCall [
        str(_display), { createHashMap }, true
    ];

    DBG_1("Invoking Create function for control type %1", _itemType);
    _ctrl = [_self, _itemAttrs, _display] call (_self get Q(Creators) get _itemType);
    _ctrl setVariable [P_TYPE, _itemType];
    _ctrl setVariable [P_TAG, _itemAttrs get A_TAG];
    _ctrl setVariable [P_HANDLER, _self];

    _controls pushBack _ctrl;
    _taggedControls set [_itemAttrs get A_TAG, _ctrl];
    if (_display isEqualTo (findDisplay 46)) then {
        uiNamespace setVariable [
            Q(dzn_ControlHandler_MainGameControls),
            (uiNamespace getVariable [Q(dzn_ControlHandler_MainGameControls), []]) + [_ctrl]
        ];
    }
};

// -- Re-save attrs each time to handle modify
_ctrl setVariable [P_ATTRS, _itemAttrs];

DBG_1("Invoking Rendering function for control type %1", _itemType);
[_self, _ctrl, _itemAttrs] call (_self get Q(Renderers) get _itemType);

DBG("Rendered!");

_ctrl