#include "defines.h"

params ["_cob"];

// Header
private _typeNames = Q(BUTTON);

private _parse = {
    LOG_ "[parse.Button] Parsing. Params: %1", _this EOL;
    params ["_cob", "_item", "_itemDescriptor", "_idx"];
    // [ 0@Type("BUTTON"), 1@Title, 2@Code, 3@Args, 4(optional)@Attrs, 5(optional)@Events ]
    _itemDescriptor params [
        "",
        "_title",
        ["_callback", { closeDialog 2; }],
        ["_args", []],
        ["_attrs", []],
        ["_events", []]
    ];

    _item set [A_TITLE, _title];
    _item set [A_CALLBACK, _callback];
    _item set [A_CALLBACK_ARGS, _args];
    _item set [A_BG, ITEM_BG_COLOR_RGBA];
    _item set [A_EVENTS, _events];
    PARSING_APPLY_ATTRIBUTES;
};

#define BTN_OFFSETS 0.002

private _render = {
    LOG_ "[render.Button] Rendering. Params: %1", _this EOL;
    params ["_cob", "_item", "_xOffset", "_yOffset", "_itemWidth", "_itemHeight", "_dialog", "_ctrlGroup"];
    _ctrl = _dialog ctrlCreate [RSC_BUTTON, -1, _ctrlGroup];
    _ctrl ctrlSetStructuredText parseText (_item get A_TITLE);

    _ctrl ctrlAddEventHandler ["ButtonClick", _cob get F(onButtonClick)];
    _ctrl setVariable [A_CALLBACK, _item get A_CALLBACK];
    _ctrl setVariable [A_CALLBACK_ARGS, _item get A_CALLBACK_ARGS];

    LOG_ "[render.Button] Callback=%1, CallbackArg=%2", _item get A_CALLBACK, _item get A_CALLBACK_ARGS EOL;

    // Add some room around the button
    SET_POSITION(_ctrl, _xOffset + BTN_OFFSETS, _yOffset + BTN_OFFSETS, _itemWidth - (2*BTN_OFFSETS), _itemHeight - (2*BTN_OFFSETS));
    SET_ATTRIBURES(_ctrl);
    SET_EVENTS(_ctrl);

    _ctrl ctrlSetActiveColor [1,0,0,1];

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _render]];
