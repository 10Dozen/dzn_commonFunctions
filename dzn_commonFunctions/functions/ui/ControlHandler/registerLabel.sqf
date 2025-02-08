#include "defines.h"

params ["_cob"];

// Label
private _typeNames = Q(LABEL);

private _parse = {
    #define DBG_FUNC_PREFIX "Label.Parse"
    DBG_1("Params: %1", _this);
    params ["_cob", "_itemAttrs", "_itemDescriptor", ["_ctrl", controlNull]];
    // [ 0@Type(LABEL), 1@Title, 2(opt)@Attrs, 3(opt)@Events ]

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
    _itemAttrs set [A_EVENTS, _events];
    _cob call [F(MergeAttributes), [_itemAttrs, _attrs]];
};

private _create = {
    #define DBG_FUNC_PREFIX "Label.Create"
    DBG_1("Params: %1", _this);
    params ["_cob", "_itemsAttrs", "_dialog", ["_ctrlGroup", controlNull]];
    private _ctrl = _dialog ctrlCreate [RSC_LABEL, -1, _ctrlGroup];

    _ctrl
};

private _render = {
    #define DBG_FUNC_PREFIX "Label.Render"
    DBG_1("Params: %1", _this);

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

    if (_itemAttrs getOrDefault [A_ADJUST_HEIGHT, false]) then {
        _ctrl ctrlSetPosition [
            _itemAttrs get A_X,
            _itemAttrs get A_Y,
            _itemAttrs get A_W,
            ctrlTextHeight _ctrl
        ];
        _ctrl ctrlCommit 0;
    };

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _create, _render]];
