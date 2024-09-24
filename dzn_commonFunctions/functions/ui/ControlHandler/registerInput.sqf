#include "defines.h"

params ["_cob"];

// Header
private _typeNames = [ Q(INPUT), Q(INPUT_AREA) ];

private _parse = {
    LOG_ "[parse.Input] Parsing. Params: %1", _this EOL;
    params ["_cob", "_itemAttrs", "_itemDescriptor", ["_ctrl", controlNull], "_idx"];
    // [ 0@Type("INPUT"), 1@DefaultValue(str), 2@(optional)Various ]
    
    if (!isNull _ctrl) then {
        _itemDescriptor = [
            "",
            ctrlText _ctrl,
            _itemDescriptor # 0,
            _itemDescriptor # 1
        ];
        
        LOG_ "[parse.Input] On modify: %1", _itemDescriptor EOL;
    };

    _itemDescriptor params [
        "",
        ["_defaultValue", ""],
        ["_attrs", []],
        ["_events", []]
    ];
    _itemAttrs set [A_VALUE, _defaultValue];
    _itemAttrs set [A_BG, ITEM_BG_COLOR_RGBA];
    _itemAttrs set [A_EVENTS, _events];
    _cob call [F(MergeAttributes), [_itemAttrs, _attrs]];
};

private _create = {
    LOG_ "[create.Input] Rendering. Params: %1", _this EOL;
    params ["_cob", "_itemsAttrs", "_dialog", ["_ctrlGroup", controlNull]];
    private _ctrl = _dialog ctrlCreate [
        [RSC_INPUT_AREA, RSC_INPUT] select ((_itemAttrs get A_TYPE) == Q(INPUT)),
        -1,
        _ctrlGroup
    ];

    _ctrl
};

private _render = {
    LOG_ "[render.Input] Rendering. Params: %1", _this EOL;

    params ["_cob", "_ctrl", "_itemAttrs"];
    _ctrl ctrlSetPosition [
        _itemAttrs get A_X,
        _itemAttrs get A_Y,
        _itemAttrs get A_W,
        _itemAttrs get A_H
    ];

    _ctrl ctrlSetText (_itemAttrs get A_VALUE);

    SET_COMMON_ATTRIBURES(_ctrl,_itemAttrs);
    SET_EVENT_HANDLERS(_ctrl,_itemAttrs,_cob);
    REGISTER_AS_INPUT;

    _ctrl ctrlCommit 0;
    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _create, _render]];
