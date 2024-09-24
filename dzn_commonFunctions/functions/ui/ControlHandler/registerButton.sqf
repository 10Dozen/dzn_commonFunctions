#include "defines.h"

params ["_cob"];

// Header
private _typeNames = Q(BUTTON);

private _parse = {
    LOG_ "[parse.Button] Parsing. Params: %1", _this EOL;
    params ["_cob", "_itemAttrs", "_itemDescriptor", ["_ctrl", controlNull]];
    // [ 0@Type("BUTTON"), 1@Title, 2@Code, 3@Args, 4(optional)@Attrs, 5(optional)@Events ]

    if (!isNull _ctrl) then {
        _itemDescriptor = [
            "",
            _itemAttrs get A_TITLE,
            _itemAttrs get A_CALLBACK,
            _itemAttrs get A_CALLBACK_ARGS,
            _itemDescriptor # 0,
            _itemDescriptor # 1
        ];
        
        LOG_ "[parse.Button] On modify: %1", _itemDescriptor EOL;
    };

    _itemDescriptor params [
        "",
        "_title",
        ["_callback", {}],
        ["_args", []],
        ["_attrs", []],
        ["_events", []]
    ];

    _itemAttrs set [A_TITLE, _title];
    _itemAttrs set [A_CALLBACK, _callback];
    _itemAttrs set [A_CALLBACK_ARGS, _args];
    _itemAttrs set [A_BG, ITEM_BG_COLOR_RGBA];
    _itemAttrs set [A_EVENTS, _events];
    _cob call [F(MergeAttributes), [_itemAttrs, _attrs]];
};

private _create = {
    LOG_ "[create.Button] Params: %1", _this EOL;
    params ["_cob", "_itemsAttrs", "_dialog", ["_ctrlGroup", controlNull]];
    
    private _ctrl = _dialog ctrlCreate [
        RSC_BUTTON, 
        -1, 
        _ctrlGroup
    ];
    _ctrl ctrlAddEventHandler ["ButtonClick", _cob get F(onButtonClick)];

    _ctrl
};

#define BTN_OFFSETS 0.002
private _render = {
    LOG_ "[render.Button] Update rendering. Params: %1", _this EOL;
    params ["_cob", "_ctrl", "_itemAttrs"];

    // Add some room around the button
    _ctrl ctrlSetPosition [
        (_itemAttrs get A_X) + BTN_OFFSETS, 
        (_itemAttrs get A_Y) + BTN_OFFSETS,
        (_itemAttrs get A_W) - (2*BTN_OFFSETS),
        (_itemAttrs get A_H) - (2*BTN_OFFSETS)
    ];

    _ctrl ctrlSetStructuredText parseText (_itemAttrs get A_TITLE);
    // _ctrl ctrlSetActiveColor (_itemAttrs getOrDefault [A_COLOR_ACTIVE, COLOR_ACTIVE_DEFAULT]);
    SET_COMMON_ATTRIBURES(_ctrl,_itemAttrs);

    LOG_ "[render.Button] Callback=%1, CallbackArg=%2", _itemAttrs get A_CALLBACK, _itemAttrs get A_CALLBACK_ARGS EOL;
    _ctrl setVariable [P_CALLBACK, _itemAttrs get A_CALLBACK];
    _ctrl setVariable [P_CALLBACK_ARGS, _itemAttrs get A_CALLBACK_ARGS];

    LOG_ "[render.Button] Going to set EH callbacks and args: %1", _itemAttrs get A_EVENTS EOL;
    SET_EVENT_HANDLERS(_ctrl,_itemAttrs,_cob);

    _ctrl ctrlCommit 0;
    _ctrl 
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _create, _render]];
