#include "defines.h"

params ["_cob"];

// Label
private _typeNames = Q(LABEL);

private _parse = {
    LOG_ "[parse.Label] Parsing. Params: %1", _this EOL;
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
    LOG_ "[render.Label] Rendering. Params: %1", _this EOL;

    params ["_cob", "_item", "_xOffset", "_yOffset", "_itemWidth", "_itemHeight", "_dialog", "_ctrlGroup"];
    private _ctrl = _dialog ctrlCreate [RSC_LABEL, -1, _ctrlGroup];
    _ctrl ctrlSetStructuredText parseText (_item get A_TITLE);
    SET_ATTRIBURES(_ctrl);
    SET_EVENTS(_ctrl);
    SET_POSITION(_ctrl, _item, _xOffset, _yOffset, _itemWidth, _itemHeight);

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _render]];
