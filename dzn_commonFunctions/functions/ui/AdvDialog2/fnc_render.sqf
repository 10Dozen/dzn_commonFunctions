#include "defines.h"

/*
    Renders COB.Items and shows dialog on screen.

    Params:
        nothing (refers to COB.Items and COB.LineHeights properties)
    Retunrs:
        nothing
*/

DBG_1("Params: %1", _this);
DBG("Rendering started");

DBG_1("OnParsed script: %1", _self get F(OnParsed));
DBG_1("OnParsed script execution with args: %1", _self get Q(OnParsedArgs));

_self call [F(OnParsed), [_self, _self get Q(OnParsedArgs)]];

private _dialogAttrs = _self get Q(DialogAttributes);
private _dialogX = _dialogAttrs get A_X;
private _dialogY = _dialogAttrs get A_Y;
private _dialogW = _dialogAttrs get A_W;
private _dialogH = _dialogAttrs get A_H;

private _dialog = _dialogAttrs get A_DIALOG;
if (isNil "_dialog") then {
    createDialog DIALOG_NAME;
    _dialog = findDisplay DIALOG_ID;
};
_self set [Q(Dialog), _dialog];
_self set [Q(DialogID), _dialogAttrs getOrDefault [A_DIALOG_ID, ""]];

private _ctrlGroup = _dialog ctrlCreate [RSC_GROUP, -1];
_ctrlGroup ctrlSetPosition [_dialogX + _dialogW/2, 0, 0, 0];
_ctrlGroup ctrlCommit 0;

private _background = _dialog ctrlCreate [RSC_BG, -1, _ctrlGroup];

private _allCtrls = [_ctrlGroup, _background];
private _plainControlsList = [];
private _perLineControls = [];
private _inputs = [];
private _taggedControls = createHashMap;

private _linesHeights = _self get Q(LineHeights);
private _yOffset = 0;

{
    private _lineNo = _forEachIndex;
    private _lineControls = [];
    private _lineItems = _x;
    private _lineHeight = _linesHeights # _lineNo;
    private _xOffset = 0;

    DBG_2("Line number = %1, with %2 items", _lineNo, count _lineItems);
    DBG_1("Line height: %1", _lineHeight);

    {
        DBG_2("Adding new control to line %1, descriptor: %2", _lineNo + 1, _x);

        private _item = _x;
        private _itemType = _item get A_TYPE;
        private _itemWidth = _dialogW * (_item get A_W);
        private _itemHeight = _item get A_H;

        DBG_4("Auto-layout for item: x=%1, y=%2, width=%3, height=%4", _xOffset, _yOffset, _itemWidth, _itemHeight);
        DBG_1("Invoking Render function for control type %1", _itemType);

        private _ctrl = [
            _self, _item,
            _xOffset, _yOffset, _itemWidth, _itemHeight,
            _dialog, _ctrlGroup
        ] call (_self get Q(Renderers) get _itemType);

        DBG_1("Finalizing item: _enabled=%1", _item get A_ENABLED);
        _ctrl ctrlEnable (_item get A_ENABLED);
        _ctrl setVariable [Q(type), _itemType];
        _ctrl setVariable [Q(tag), _item get A_TAG];
        _taggedControls set [_item get A_TAG, _ctrl];

        if (_ctrl getVariable [Q(isInput), false]) then {
            _inputs pushBack _ctrl;
        };

        _xOffset = _xOffset + _itemWidth;
        _lineHeight = _lineHeight max (_ctrl getVariable [Q(AdjustedHeight), _lineHeight]);

        _lineControls pushBack _ctrl;
        _plainControlsList pushBack _ctrl;
        _allCtrls append (_ctrl getVariable [Q(GroupedCtrls), [_ctrl]]);
    } forEach _lineItems;

    _perLineControls pushBack _lineControls;
    _yOffset = _yOffset + _lineHeight;
} forEach (_self get Q(Items));

_dialog setVariable [Q(AllDialogControls), _allCtrls];
_dialog setVariable [Q(Controls), _plainControlsList];
_dialog setVariable [Q(ControlsPerLines), _perLineControls];
_dialog setVariable [Q(Inputs), _inputs];
_dialog setVariable [Q(TaggedControls), _taggedControls];

_background ctrlSetBackgroundColor (_dialogAttrs getOrDefault [A_BG, BG_COLOR_RGBA]);

// If first item is a Header -- do not draw background underneath and start BG from next line
// otherwise - fill bg starting from 1st line.
private _topItemIsHeader = ((_self get Q(Items)) # 0 # 0) get A_TYPE == Q(HEADER);
_background ctrlSetPosition ([
    [0, 0, _dialogW, _yOffset],
    [0, (_linesHeights # 0), _dialogW,  _yOffset - (_linesHeights # 0)]
] select _topItemIsHeader);

_background ctrlCommit 0;

_ctrlGroup ctrlSetPosition [_dialogX, _dialogY, _dialogW, _dialogH min _yOffset];
_ctrlGroup ctrlCommit (_dialogAttrs getOrDefault [A_DIALOG_SHOW_TIME, DIALOG_SHOW_TIME]);

DBG_1("OnDraw script execution with args: %1", _self get Q(OnDrawArgs));
_self call [F(OnDraw), [_self, _self get Q(OnDrawArgs)]];

DBG("Rendered!");
