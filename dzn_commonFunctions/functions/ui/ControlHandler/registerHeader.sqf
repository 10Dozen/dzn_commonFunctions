#include "defines.h"

params ["_cob"];

// Header
private _typeNames = Q(HEADER);

private _parse = {
    #define DBG_FUNC_PREFIX "Header.Parse"
    DBG_1("Params: %1", _this);

    params ["_cob", "_itemAttrs", "_itemDescriptor", ["_ctrl", controlNull], "_idx"];
    // [ 0@Type("HEADER"), 1@Title, 2(optional)@Various, 3(optional)@Events ]
    if (!isNull _ctrl) then {
        _itemDescriptor = [
            "",
            _itemAttrs get A_TITLE,
            _itemDescriptor # 0,
            _itemDescriptor # 1
        ];
        DBG_1("On modify: %1", _itemDescriptor);
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
    #define DBG_FUNC_PREFIX "Header.Create"
    DBG_1("Params: %1", _this);
    params ["_cob", "_itemsAttrs", "_dialog", ["_ctrlGroup", controlNull]];

    private _ctrl = _dialog ctrlCreate [RSC_HEADER, -1, _ctrlGroup];
    // TBD: Close button support?

    _ctrl
};

private _render = {
    #define DBG_FUNC_PREFIX "Header.Render"
    DBG_1("Params: %1", _this);
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
