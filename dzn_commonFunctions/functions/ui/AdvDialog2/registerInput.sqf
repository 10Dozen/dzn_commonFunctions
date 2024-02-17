#include "defines.h"

params ["_cob"];

// Header
private _typeNames = [ Q(INPUT), Q(INPUT_AREA) ];

private _parse = {
    LOG_ "[parse.Input] Parsing. Params: %1", _this EOL;
    params ["_cob", "_item", "_itemDescriptor", "_idx"];
    // [ 0@Type("INPUT"), 1@DefaultValue(str), 2@(optional)Various ]
   _itemDescriptor params [
       "",
       ["_defaultValue", ""],
       ["_attrs", []],
       ["_events", []]
   ];
   _item set [A_SELECTED, _defaultValue];
   _item set [A_BG, ITEM_BG_COLOR_RGBA];
   _item set [A_EVENTS, _events];
   PARSING_APPLY_ATTRIBUTES;
};

private _render = {
    LOG_ "[render.Input] Rendering. Params: %1", _this EOL;

    params ["_cob", "_item", "_xOffset", "_yOffset", "_itemWidth", "_itemHeight", "_dialog", "_ctrlGroup"];
    _ctrl = _dialog ctrlCreate [
        [RSC_INPUT_AREA, RSC_INPUT] select ((_item get A_TYPE) == Q(INPUT)),
        -1,
        _ctrlGroup
    ];
    _ctrl ctrlSetText (_item get A_SELECTED);

    SET_ATTRIBURES(_ctrl);
    SET_EVENTS(_ctrl);
    SET_POSITION(_ctrl, _xOffset, _yOffset, _itemWidth, _itemHeight);
    REGISTER_AS_INPUT;

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _render]];
