#include "defines.h"

params ["_cob"];

// Header
private _typeNames = Q(SLIDER);

private _parse = {
    LOG_ "[parse.Slider] Parsing. Params: %1", _this EOL;

    params ["_cob", "_item", "_itemDescriptor", "_idx"];
    // [ 0@Type("SLIDER"), 1@[@Min,@Max,@Decimal], 2(optional)@DefaultPosition, 3@(optional)Attrs, 4(optional)@Events ]
    _itemDescriptor params [
        "",
        "_sliderParams",
        ["_defaultPosition", _itemDescriptor # 1 # 0], // Defaults to range Min
        ["_attrs", []],
        ["_events", []]
    ];

    _item set [A_SELECTED, _defaultPosition];
    _item set [A_SLIDER_RANGE, _sliderParams];
    _item set [A_BG, ITEM_BG_COLOR_RGBA];
    _item set [A_EVENTS, _events];
    PARSING_APPLY_ATTRIBUTES;
};

private _render = {
    LOG_ "[render.Slider] Rendering. Params: %1", _this EOL;

    params ["_cob", "_item", "_xOffset", "_yOffset", "_itemWidth", "_itemHeight", "_dialog", "_ctrlGroup"];
    _ctrl = _dialog ctrlCreate [RSC_SLIDER, -1, _ctrlGroup];

    (_item get A_SLIDER_RANGE) params ["_rangeMin", "_rangeMax", "_speed"];
    _ctrl sliderSetSpeed [_speed, _speed * 10, _speed];
    _ctrl sliderSetRange [_rangeMin, _rangeMax];
    _ctrl sliderSetPosition (_item get A_SELECTED);

    SET_ATTRIBURES(_ctrl);
    _ctrl setVariable [Q(sliderCustomTooltip), _item get A_TOOLTIP];
    _ctrl ctrlAddEventHandler ["SliderPosChanged", _cob get F(onSliderChanged)];
    _cob call [F(onSliderChanged), [_ctrl, (_item get A_SELECTED)]];

    SET_EVENTS(_ctrl);
    SET_POSITION(_ctrl, _item, _xOffset, _yOffset, _itemWidth, _itemHeight);
    REGISTER_AS_INPUT;

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _render]];
