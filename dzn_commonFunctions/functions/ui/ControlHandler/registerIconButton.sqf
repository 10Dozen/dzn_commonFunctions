#include "defines.h"

params ["_cob"];

// Header
private _typeNames = Q(ICON_BUTTON);

private _parse = {
    #define DBG_FUNC_PREFIX "IconButton.Parse"
    DBG_1("Params: %1", _this);

    params ["_cob", "_itemAttrs", "_itemDescriptor", ["_ctrl", controlNull], "_idx"];
    // [ 0@Type("ICON_BUTTON"), 1@Icon, 2@Code, 3(optional)@Args, 4(optional)@Attributes, 5(optional)@Events]
    if (!isNull _ctrl) then {
        _itemDescriptor = [
            "",
            _itemAttrs get A_ICON,
            _itemAttrs get A_CALLBACK,
            _itemAttrs get A_CALLBACK_ARGS,
            _itemDescriptor # 0,
            _itemDescriptor # 1
        ];
        DBG_1("On modify: %1", _itemDescriptor);
    };
    _itemDescriptor params [
        "",
        "_icon",
        "_callback",
        ["_args", []],
        ["_attrs", []],
        ["_events", []]
    ];

    _itemAttrs set [A_ICON, _icon];
    _itemAttrs set [A_CALLBACK, _callback];
    _itemAttrs set [A_CALLBACK_ARGS, _args];
    _itemAttrs set [A_BG, ITEM_BG_COLOR_RGBA];
    _itemAttrs set [A_EVENTS, _events];
    _itemAttrs set [A_ICON_SQUARED, true];
    _cob call [F(MergeAttributes), [_itemAttrs, _attrs]];
};

private _create = {
    #define DBG_FUNC_PREFIX "IconButton.Create"
    DBG_1("Params: %1", _this);
    params ["_cob", "_itemsAttrs", "_dialog", ["_ctrlGroup", controlNull]];

    private _ctrl = _dialog ctrlCreate [RSC_BUTTON_PICTURE, -1, _ctrlGroup];
    _ctrl ctrlAddEventHandler ["ButtonClick", _cob get F(onButtonClick)];

    _ctrl
};

#define BTN_OFFSETS 0.002
private _render = {
    #define DBG_FUNC_PREFIX "IconButton.Render"
    DBG_1("Rendering. Params: %1", _this);
    params ["_cob", "_ctrl", "_itemAttrs"];

    private _h = (_itemAttrs get A_SIZE) max (_itemAttrs get A_H);
    private _w = [
        _itemAttrs get A_W,
        _h * SAFEZONE_ASPECT_RATIO
    ] select (_itemAttrs get A_ICON_SQUARED);

    _ctrl ctrlSetPosition [
        (_itemAttrs get A_X) + BTN_OFFSETS,
        (_itemAttrs get A_Y) + BTN_OFFSETS,
        _w - (2*BTN_OFFSETS),
        _h - (2*BTN_OFFSETS)
    ];

    DBG_1("ctrlSetText text=%1", _itemAttrs get A_ICON);
    _ctrl ctrlSetText (_itemAttrs get A_ICON);
    SET_COMMON_ATTRIBURES(_ctrl,_itemAttrs);

    DBG_2("Callback=%1, CallbackArg=%2", _itemAttrs get A_CALLBACK, _itemAttrs get A_CALLBACK_ARGS);
    _ctrl setVariable [P_CALLBACK, _itemAttrs get A_CALLBACK];
    _ctrl setVariable [P_CALLBACK_ARGS, _itemAttrs get A_CALLBACK_ARGS];

    DBG_1("Going to set EH callbacks and args: %1", _itemAttrs get A_EVENTS);
    SET_EVENT_HANDLERS(_ctrl,_itemAttrs,_cob);

    _ctrl ctrlCommit 0;
    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _create, _render]];
