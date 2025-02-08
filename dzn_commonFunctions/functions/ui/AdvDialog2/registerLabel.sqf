#include "defines.h"
DBG_1("Params: %1", _this);
params ["_cob"];

// Label
private _typeNames = Q(LABEL);

private _parse = {
    #define DBG_FUNC_PREFIX "Label.Parse"
    DBG_1("Params: %1", _this);

    params ["_cob", "_item", "_itemDescriptor", "_idx"];
    // [ 0@Type(LABEL), 1@Title, 2(opt)@Attrs, 3(opt)@Events ]
    _itemDescriptor params [
        "",
        ["_title", ""],
        ["_attrs", []],
        ["_events", []]
    ];
    _item set [A_TITLE, _title];
    _item set [A_EVENTS, _events];
    PARSING_APPLY_ATTRIBUTES;
};

private _render = {
    #define DBG_FUNC_PREFIX "Label.Render"
    DBG_1("Params: %1", _this);

    params ["_cob", "_item", "_xOffset", "_yOffset", "_itemWidth", "_itemHeight", "_dialog", "_ctrlGroup"];
    private _ctrl = _dialog ctrlCreate [RSC_LABEL, -1, _ctrlGroup];
    _ctrl ctrlSetStructuredText parseText (_item get A_TITLE);

    SET_POSITION(_ctrl, _item, _xOffset, _yOffset, _itemWidth, _itemHeight);
    SET_ATTRIBURES(_ctrl);
    SET_EVENTS(_ctrl);

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _render]];
