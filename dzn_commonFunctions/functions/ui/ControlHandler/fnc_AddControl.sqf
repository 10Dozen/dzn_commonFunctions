#include "defines.h"

/*
    Creates control

    Params:
        _itemDescription (Array) - describes control and it's attributes:


    Returns:
        _control (Control) - created control or nil, if control with given tag already exists.
*/

params ["_display", ["_tag", ""], "_itemDescriptor"];

LOG_ "[AddControl] Params: %1", _this EOL;

// -- Prevent from adding 2 controls under the same tag
private _taggedCtrl = [];
if (_tag != "") then { 
    _taggedCtrl = _self call [F(GetByTag), [_display, _tag]]; 
    LOG_ "[AddControl] Tag is not empty - checking for occupied tag = %1", _tag EOL;
};
LOG_ "[AddControl] Same-tagged controls (%1): %2", count _taggedCtrl, str(_taggedCtrl) EOL;
if (_taggedCtrl isNotEqualTo []) exitWith {
    LOG_ "[AddControl] Control with tag '%1' already exists", _tag EOL;
    nil
};

// -- Parse attrs
private _ctrlAttrs = _self call [F(parseParams), _itemDescriptor];

// -- Apply TAG from external param or generate new one, 
//    but tag passed in Attributes won't be overwritten
if (_tag == "") then {
    _tag = format ["Untagged_%1_%2", _ctrlAttrs get A_TYPE, _self get Q(ControlIndex)];
    _self set [Q(ControlIndex), (_self get Q(ControlIndex)) + 1];
};
_ctrlAttrs set [A_TAG, _tag, true]; 

// -- Render parsed 
private _ctrl = _self call [F(render), [_display, _ctrlAttrs]];

LOG_ "[AddControl] Created control = %1", _ctrl EOL;

_ctrl