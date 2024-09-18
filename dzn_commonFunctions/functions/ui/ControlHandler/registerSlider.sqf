#include "defines.h"

params ["_cob"];

// Header
private _typeNames = Q(SLIDER);

private _parse = {
    LOG_ "[parse.Slider] Parsing. Params: %1", _this EOL;

    params ["_cob", "_itemAttrs", "_itemDescriptor", ["_ctrl", controlNull], "_idx"];
    // [ 0@Type("SLIDER"), 1@[@Min,@Max,@Decimal], 2(optional)@DefaultPosition, 3@(optional)Attrs, 4(optional)@Events ]
    
    if (!isNull _ctrl) then {
        // -- On modify (ctrl is not null) - item descriptor is array of ATTRIBUTES and EVENTS only
        _itemDescriptor = [
            "", 
            _itemAttrs get A_SLIDER_RANGE,
            sliderPosition _ctrl,
            _itemDescriptor # 0,
            _itemDescriptor # 1
        ];
        
        LOG_ "[parse.Slider] On modify: %1", _itemDescriptor EOL;
    };
    
    _itemDescriptor params [
        "",
        "_sliderParams",
        ["_defaultPosition", _itemDescriptor # 1 # 0], // Defaults to range Min
        ["_attrs", []],
        ["_events", []]
    ];

    _itemAttrs set [A_VALUE, _defaultPosition];
    _itemAttrs set [A_SLIDER_RANGE, _sliderParams];
    _itemAttrs set [A_BG, ITEM_BG_COLOR_RGBA];
    _itemAttrs set [A_EVENTS, _events];
    _cob call [F(MergeAttributes), [_itemAttrs, _attrs]];
};

private _create = {
    LOG_ "[create.Slider] Rendering. Params: %1", _this EOL;
    params ["_cob", "_itemsAttrs", "_dialog", ["_ctrlGroup", controlNull]];
    private _ctrl = _dialog ctrlCreate [RSC_SLIDER, -1, _ctrlGroup];
    _ctrl ctrlAddEventHandler ["SliderPosChanged", _cob get F(onSliderChanged)];

    _ctrl
};

private _render = {
    LOG_ "[render.Slider] Rendering. Params: %1", _this EOL;
    params ["_cob", "_ctrl", "_itemAttrs"];

    _ctrl ctrlSetPosition [
        _itemAttrs get A_X,
        _itemAttrs get A_Y,
        _itemAttrs get A_W,
        _itemAttrs get A_H
    ];


    (_itemAttrs get A_SLIDER_RANGE) params ["_rangeMin", "_rangeMax", "_speed"];
    _ctrl sliderSetSpeed [_speed, _speed * 10, _speed];
    _ctrl sliderSetRange [_rangeMin, _rangeMax];
    _ctrl sliderSetPosition (_itemAttrs get A_VALUE);

    SET_COMMON_ATTRIBURES(_ctrl,_itemAttrs);
    _ctrl setVariable [P_CUSTOM_TOOLTIP, _itemAttrs get A_TOOLTIP];
    _cob call [F(onSliderChanged), [_ctrl, (_itemAttrs get A_VALUE)]];

    SET_EVENT_HANDLERS(_ctrl,_itemAttrs,_cob);
    REGISTER_AS_INPUT;

    _ctrl ctrlCommit 0;
    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _create, _render]];
