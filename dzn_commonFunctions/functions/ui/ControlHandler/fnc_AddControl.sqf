#include "defines.h"

/*
    Creates control

    Params:
        _itemDescription (Array) - describes control and it's attributes:


    Returns:
        _control (Control) - created control or nil, if control with given tag already exists.
*/

DBG_1("Params: %1", _this);
params ["_display", ["_tag", ""], "_itemDescriptor"];


// -- Prevent from adding 2 controls under the same tag
private _taggedCtrl = [];
if (_tag != "") then {
    _taggedCtrl = _self call [F(GetByTag), [_display, _tag]];
    DBG_1("Tag is not empty - checking for occupied tag = %1", _tag);
};

DBG_2("Same-tagged controls (%1): %2", count _taggedCtrl, str(_taggedCtrl));
if (_taggedCtrl isNotEqualTo []) exitWith {
    DBG_1("Control with tag '%1' already exists", _tag);
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

["dzn_ControlHandler_onControlAdded", [_self, _display, _ctrl]] call CBA_fnc_localEvent;

DBG_1("[AddControl] Created control = %1", _ctrl);

_ctrl