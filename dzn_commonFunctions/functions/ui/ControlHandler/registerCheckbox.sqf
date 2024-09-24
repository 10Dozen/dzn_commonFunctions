#include "defines.h"

params ["_cob"];

// Header
private _typeNames = [ Q(CHECKBOX), Q(CHECKBOX_RIGHT) ];

private _parse = {
    LOG_ "[parse.Checkbox] Parsing. Params: %1", _this EOL;

    params ["_cob", "_itemAttrs", "_itemDescriptor", ["_ctrl", controlNull], "_idx"];
    // [ 0@Type, 1@Title, 2(optional)@DefaultState, 3(optional)@Attrs, 4(optional)@Events ]
    
    if (!isNull _ctrl) then {
        _itemDescriptor = [
            "",
            _itemAttrs get A_TITLE,
            cbChecked _ctrl,
            _itemDescriptor # 0,
            _itemDescriptor # 1
        ];
        LOG_ "[parse.Checkbox] On modify: %1", _itemDescriptor EOL;
    };

    _itemDescriptor params [
        "",
        "_title",
        ["_defaultState", false],
        ["_attrs", []],
        ["_events", []]
    ];

    _itemAttrs set [A_TITLE, _title];
    _itemAttrs set [A_VALUE, _defaultState];
    _itemAttrs set [A_EVENTS, _events];
    _cob call [F(MergeAttributes), [_itemAttrs, _attrs]];
};

private _create = {
    LOG_ "[create.Checkbox] Params: %1", _this EOL;
    params ["_cob", "_itemsAttrs", "_dialog", ["_ctrlGroup", controlNull]];
    
    private _ctrl = _dialog ctrlCreate [RSC_CHECKBOX, -1, _ctrlGroup];
    private _ctrlTitle = _dialog ctrlCreate [RSC_LABEL, -1, _ctrlGroup];

    _ctrl setVariable [P_SUBCONTROL, _ctrlTitle];
    _ctrlTitle setVariable [P_RELATED_CHECKBOX, _ctrl];

    // Handle click on text to change checkbox state
    _ctrlTitle ctrlAddEventHandler ["MouseButtonUp", _cob get F(onChekboxLabelClicked)];
   
    _ctrl
};

#define CB_TEXT_OFFSET 0.004
#define CB_HEIGHT_OFFSET LINE_HEIGHT_OFFSET / 2
private _render = {
    LOG_ "[render.Checkbox] Rendering. Params: %1", _this EOL;
    params ["_cob", "_ctrl", "_itemAttrs"];

    private _ctrlTitle = _ctrl getVariable P_SUBCONTROL;
    private _cbHeight = _itemAttrs get A_SIZE;
    private _cbWidth = _cbHeight * SAFEZONE_ASPECT_RATIO;
    private _titleWidth = (_itemAttrs get A_W) - _cbWidth - CB_TEXT_OFFSET;
    private _titleHeight = _cbHeight max (_itemAttrs get A_H);

    private _xPos = _itemAttrs get A_X;
    private _yPos = _itemAttrs get A_Y;

    // [ ] Title
    private _cbOffsetX = _xPos;
    private _titleOffsetX = _xPos + _cbWidth + CB_TEXT_OFFSET;
    private _cbOffsetY = _yPos + CB_HEIGHT_OFFSET;
    // Title [ ]
    if (_itemType == Q(CHECKBOX_RIGHT)) then {
        _cbOffsetX = _xPos + _titleWidth + CB_TEXT_OFFSET;
        _titleOffsetX = _xPos;
    };

    REGISTER_AS_INPUT;
    SET_COMMON_ATTRIBURES(_ctrl,_itemAttrs);
    SET_COMMON_ATTRIBURES(_ctrlTitle,_itemAttrs);

    SET_EVENT_HANDLERS(_ctrl,_itemAttrs,_cob);
    SET_EVENT_HANDLERS(_ctrlTitle,_itemAttrs,_cob);

    LOG_ 
        "[render.Checkbox] _cbOffsetX=%1, _cbOffsetY=%2, _cbWidth=%3, _cbHeight=%4, _titleOffsetX=%5", 
        _cbOffsetX, 
        _cbOffsetY, 
        _cbWidth, 
        _cbHeight,
        _titleOffsetX
    EOL;

    _ctrl ctrlSetPosition [_cbOffsetX, _cbOffsetY, _cbWidth, _cbHeight];
    _ctrlTitle ctrlSetPosition [_titleOffsetX, _yPos, _titleWidth, _titleHeight];
    _ctrl ctrlCommit 0;
    _ctrlTitle ctrlCommit 0;

    _ctrl cbSetChecked (_itemAttrs get A_VALUE);
    _ctrl ctrlSetChecked (_itemAttrs get A_VALUE);
    _ctrlTitle ctrlSetStructuredText parseText (_itemAttrs get A_TITLE);

    _ctrl
};

private _remove = {
    LOG_ "[render.Checkbox] Rendering. Params: %1", _this EOL;
    params ["_cob", "_ctrl"];

    ctrlDelete (_ctrl getVariable P_SUBCONTROL);
    ctrlDelete _ctrl;
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _create, _render, _remove]];
