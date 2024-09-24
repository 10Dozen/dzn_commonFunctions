#include "defines.h"

params ["_cob"];

// Header
private _typeNames = Q(HEADER);

private _parse = {
    LOG_ "[parse.Header] Parsing. Params: %1", _this EOL;

    params ["_cob", "_itemAttrs", "_itemDescriptor", ["_ctrl", controlNull], "_idx"];
    // [ 0@Type("HEADER"), 1@Title, 2(optional)@Various, 3(optional)@Events ]
    if (!isNull _ctrl) then {
        _itemDescriptor = [
            "",
            _itemAttrs get A_TITLE,
            _itemDescriptor # 0,
            _itemDescriptor # 1
        ];
        LOG_ "[parse.Header] On modify: %1", _itemDescriptor EOL;
    };
    _itemDescriptor params [
        "",
        ["_title", ""],
        ["_attrs", []],
        ["_events", []]
    ];

    _itemAttrs set [A_TITLE, _title];
    _itemAttrs set [A_BG, HEADER_BG_COLOR_RGBA];
    _itemAttrs set [A_EVENTS, _events];
    _cob call [F(MergeAttributes), [_itemAttrs, _attrs]];
};

private _create = {
    LOG_ "[render.Header] Creating. Params: %1", _this EOL;
    params ["_cob", "_itemsAttrs", "_dialog", ["_ctrlGroup", controlNull]];

    private _ctrl = _dialog ctrlCreate [RSC_HEADER, -1, _ctrlGroup];
    // TBD: Close button support?  

    _ctrl
};

private _render = {
    LOG_ "[render.Header] Rendering. Params: %1", _this EOL;
    params ["_cob", "_ctrl", "_itemAttrs"];

    _ctrl ctrlSetStructuredText parseText (_itemAttrs get A_TITLE);
    _ctrl ctrlSetPosition [
        _itemAttrs get A_X, _itemAttrs get A_Y,
        _itemAttrs get A_W, _itemAttrs get A_H
    ];

    SET_COMMON_ATTRIBURES(_ctrl,_itemAttrs);
    SET_EVENT_HANDLERS(_ctrl,_itemAttrs,_cob);

    _ctrl ctrlCommit 0;
    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _create, _render]];
