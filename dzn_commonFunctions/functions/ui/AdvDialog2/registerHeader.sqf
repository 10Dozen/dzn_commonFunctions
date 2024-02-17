#include "defines.h"

params ["_cob"];

// Header
private _typeNames = Q(HEADER);

private _parse = {
    LOG_ "[parse.Header] Parsing. Params: %1", _this EOL;

    params ["_cob", "_item", "_itemDescriptor", "_idx"];
    // [ 0@Type("HEADER"), 1@Title, 2(optional)@Various, 3(optional)@Events ]
    _itemDescriptor params [
        "",
        ["_title", ""],
        ["_attrs", []],
        ["_events", []]
    ];

    _item set [A_TITLE, _title];
    _item set [A_BG, HEADER_BG_COLOR_RGBA];
    _item set [A_EVENTS, _events];
    PARSING_APPLY_ATTRIBUTES;
    _cob call [F(AppendLinebreak), _idx];
};

private _render = {
    LOG_ "[render.Header] Rendering. Params: %1", _this EOL;
    params ["_cob", "_item", "_xOffset", "_yOffset", "_itemWidth", "_itemHeight", "_dialog", "_ctrlGroup"];

    private _iconHeigth = _item get A_SIZE;
    private _iconWidth = _iconHeigth * SAFEZONE_ASPECT_RATIO;

    private _ctrl = _dialog ctrlCreate [RSC_HEADER, -1, _ctrlGroup];
    _ctrl ctrlSetStructuredText parseText (_item get A_TITLE);

    SET_POSITION(_ctrl, 0, _yOffset, _itemWidth - _iconWidth, _itemHeight - LINE_HEIGHT_OFFSET);
    SET_ATTRIBURES(_ctrl);
    SET_EVENTS(_ctrl);

    private _ctrlCloseBtn = _dialog ctrlCreate [RSC_BUTTON_PICTURE, -1, _ctrlGroup];
    _ctrlCloseBtn ctrlSetText PICTURE_CLOSE;
    _ctrlCloseBtn ctrlAddEventHandler ["ButtonClick", { closeDialog 2 }];

    SET_POSITION(_ctrlCloseBtn, _itemWidth - _iconWidth, _yOffset, _iconWidth, _iconHeigth);

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _render]];
