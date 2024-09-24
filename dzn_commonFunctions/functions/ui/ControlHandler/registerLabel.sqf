#include "defines.h"

params ["_cob"];

// Label
private _typeNames = Q(LABEL);

private _parse = {
    LOG_ "[parse.Label] Parsing. Params: %1", _this EOL;
    params ["_cob", "_itemAttrs", "_itemDescriptor", ["_ctrl", controlNull]];
    // [ 0@Type(LABEL), 1@Title, 2(opt)@Attrs, 3(opt)@Events ]

    if (!isNull _ctrl) then {
        _itemDescriptor = [
            "",
            _item get A_TITLE,
            _itemDescriptor # 0,
            _itemDescriptor # 1
        ];
        
        LOG_ "[parse.Label] On modify: %1", _itemDescriptor EOL;
    };

    _itemDescriptor params [
        "",
        ["_title", ""],
        ["_attrs", []],
        ["_events", []]
    ];
    _itemAttrs set [A_TITLE, _title];
    _itemAttrs set [A_EVENTS, _events];
    _cob call [F(MergeAttributes), [_itemAttrs, _attrs]];
};

private _create = {
    LOG_ "[create.Label] Rendering. Params: %1", _this EOL;
    params ["_cob", "_itemsAttrs", "_dialog", ["_ctrlGroup", controlNull]];
    private _ctrl = _dialog ctrlCreate [RSC_LABEL, -1, _ctrlGroup];

    _ctrl
};

private _render = {
    LOG_ "[render.Label] Rendering. Params: %1", _this EOL;

    params ["_cob", "_ctrl", "_itemAttrs"];
    _ctrl ctrlSetPosition [
        _itemAttrs get A_X,
        _itemAttrs get A_Y,
        _itemAttrs get A_W,
        _itemAttrs get A_H
    ];
    _ctrl ctrlSetStructuredText parseText (_itemAttrs get A_TITLE);

    SET_COMMON_ATTRIBURES(_ctrl,_itemAttrs);
    SET_EVENT_HANDLERS(_ctrl,_itemAttrs,_cob);

    _ctrl ctrlCommit 0;
    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _create, _render]];
