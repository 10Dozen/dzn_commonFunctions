#include "defines.h"

params ["_cob"];

// Header
private _typeNames = [ Q(CHECKBOX), Q(CHECKBOX_RIGHT) ];

private _parse = {
    LOG_ "[parse.Checkbox] Parsing. Params: %1", _this EOL;

    params ["_cob", "_item", "_itemDescriptor", "_idx"];
    // [ 0@Type, 1@Title, 2(optional)@DefaultState, 3(optional)@Attrs, 4(optional)@Events ]
    _itemDescriptor params [
        "",
        "_title",
        ["_defaultState", false],
        ["_attrs", []],
        ["_events", []]
    ];

    _item set [A_TITLE, _title];
    _item set [A_SELECTED, _defaultState];
    _item set [A_EVENTS, _events];
    PARSING_APPLY_ATTRIBUTES;
};


#define CB_TEXT_OFFSET 0.004
#define CB_HEIGHT_OFFSET LINE_HEIGHT_OFFSET / 2
private _render = {
    LOG_ "[render.Checkbox] Rendering. Params: %1", _this EOL;

    params ["_cob", "_item", "_xOffset", "_yOffset", "_itemWidth", "_itemHeight", "_dialog", "_ctrlGroup"];

    _ctrl = _dialog ctrlCreate [RSC_CHECKBOX, -1, _ctrlGroup];
    private _ctrlTitle = _dialog ctrlCreate [RSC_LABEL, -1, _ctrlGroup];

    private _cbHeight = _item get A_SIZE;
    private _cbWidth = _cbHeight * SAFEZONE_ASPECT_RATIO;
    private _titleWidth = _itemWidth - _cbWidth - CB_TEXT_OFFSET;

    private _xPos = _item getOrDefault [A_X, _xOffset];
    private _yPos = _item getOrDefault [A_Y, _yOffset];

    // [ ] Title
    private _cbOffsetX = _xPos;
    private _titleOffsetX = _xPos + _cbWidth + CB_TEXT_OFFSET;
    // Title [ ]
    if (_itemType == Q(CHECKBOX_RIGHT)) then {
        _cbOffsetX = _xPos + _titleWidth + CB_TEXT_OFFSET;
        _titleOffsetX = _xPos;
    };

    REGISTER_AS_INPUT;
    SET_ATTRIBURES(_ctrl);
    SET_ATTRIBURES(_ctrlTitle);
    SET_EVENTS(_ctrl);
    SET_EVENTS(_ctrlTitle);

    LOG_ "[Render.Checkbox] _cbOffsetX=%1, _yOffset=%2, _cbWidth=%3, _cbHeight=%4", _cbOffsetX, _yOffset + CB_HEIGHT_OFFSET, _cbWidth, _cbHeight EOL;
    _ctrl ctrlSetPosition [_cbOffsetX, _yPos, _cbWidth, _cbHeight];
    _ctrlTitle ctrlSetPosition [_titleOffsetX, _yPos, _titleWidth, _itemHeight];
    _ctrl ctrlCommit 0;
    _ctrlTitle ctrlCommit 0;

    _ctrl cbSetChecked (_item get A_SELECTED);
    _ctrl ctrlSetChecked (_item get A_SELECTED);
    _ctrlTitle ctrlSetStructuredText parseText (_item get A_TITLE);

    // Handle click on text to change checkbox state
    _ctrlTitle ctrlAddEventHandler ["MouseButtonUp", _cob get F(onChekboxLabelClicked)];
    _ctrlTitle setVariable [Q(relatedCheckbox), _ctrl];

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _render]];
