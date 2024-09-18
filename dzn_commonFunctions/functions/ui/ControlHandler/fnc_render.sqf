#include "defines.h"

/*
    Renders COB.Items and shows dialog on screen.

    Params:
        nothing (refers to COB.Items and COB.LineHeights properties)
    Retunrs:
        nothing
*/

params ["_dialog", "_itemAttrs", ["_ctrl", controlNull]];
LOG_ "[render] Params: %1", _this EOL;

private _itemType = _itemAttrs get A_TYPE;
LOG_ "[render] Rendering started for control type %1", _itemType EOL;

if (isNull _ctrl) then {
    private _controls = _self get Q(Controls) getOrDefaultCall [str(_dialog), { [] }, true];
    private _taggedControls = _self get Q(TaggedControls) getOrDefaultCall [
        str(_dialog), { createHashMap }, true
    ];

    LOG_ "[render] Invoking Create function for control type %1", _itemType EOL;
    _ctrl = [_self, _itemAttrs, _dialog] call (_self get Q(Creators) get _itemType);
    _ctrl setVariable [P_TYPE, _itemType];
    _ctrl setVariable [P_TAG, _itemAttrs get A_TAG];
    _ctrl setVariable [P_HANDLER, _self];
    
    _controls pushBack _ctrl;
    _taggedControls set [_itemAttrs get A_TAG, _ctrl];
};

// -- Re-save attrs each time to handle modify
_ctrl setVariable [P_ATTRS, _itemAttrs];

LOG_ "[render] Invoking Rendering function for control type %1", _itemType EOL;
[_self, _ctrl, _itemAttrs] call (_self get Q(Renderers) get _itemType);

LOG_ "[render] Rendered!" EOL;

_ctrl