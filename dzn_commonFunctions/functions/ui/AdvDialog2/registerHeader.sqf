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

    private _ctrl = _dialog ctrlCreate [RSC_HEADER, -1, _ctrlGroup];
    _ctrl ctrlSetStructuredText parseText (_item get A_TITLE);

    private _headerWidth = _itemWidth;
    private _headerHeight = _itemHeight - LINE_HEIGHT_OFFSET;

    if (_item getOrDefault [A_CLOSE_BTN, true]) then {
        private _iconHeigth = _item get A_SIZE;
        private _iconWidth = _iconHeigth * SAFEZONE_ASPECT_RATIO;
        _headerWidth = _headerWidth - _iconWidth;

        private _ctrlCloseBtn = _dialog ctrlCreate [RSC_BUTTON_PICTURE, -1, _ctrlGroup];
        _ctrlCloseBtn ctrlSetText PICTURE_CLOSE;
        _ctrlCloseBtn ctrlAddEventHandler ["ButtonClick", { 
            COB call [F(Close), []];
        }];

        _ctrlCloseBtn setVariable [format ["%1_%2", "ButtonClick", A_CALLBACK], _eventCallback];
        _ctrlCloseBtn setVariable [format ["%1_%2", "ButtonClick", A_CALLBACK_ARGS], _eventCallbackArgs];
        _ctrlCloseBtn ctrlAddEventHandler ["ButtonClick", _cob get F(onEvent)];

        private _closeBtnX = (_item getOrDefault [A_X, 0]) + _itemWidth - _iconWidth;
        private _closeBtnY = _item getOrDefault [A_Y, _yOffset];
        LOG_ "[render.Position] Close icon. By props: x=%1, y=%2, w=%3, h=%4", _closeBtnX, _closeBtnY, _iconWidth, _iconHeigth  EOL;

        _ctrl setVariable [Q(GroupedCtrls), [_ctrl, _ctrlCloseBtn]];

        _ctrlCloseBtn ctrlSetPosition [_closeBtnX, _closeBtnY, _iconWidth, _iconHeigth];
        _ctrlCloseBtn ctrlCommit 0
    };

    SET_POSITION(_ctrl, _item, 0, _yOffset, _headerWidth, _headerHeight);
    SET_ATTRIBURES(_ctrl);
    SET_EVENTS(_ctrl);

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _render]];
