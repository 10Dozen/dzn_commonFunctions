/*
TODO:
    - [ok] Contol tag
    - [ok] Element width
    - [ok] Suppor attribures as hashMap syntax
    - [test] Picture button
    - lbTooltip per item for listbox/drodown

*/


/*
    [@Item1, @Item2, ..., @ItenN] call dzn_fnc_ShowAdvDialog2;

    Displays dialog of given structure of labels and inputs.

    Allows to add events to specific controls and read back current values of the inputs.
    Allows to set custom styling for each label/input using attributes (font, text and bg color).
    Labels/buttons/checkboxes support StructuredText syntax.
    Allows to add tooltips for label/input.


    Each control will be placed in the same line as the previous one until ["BR"] item is met.
    Then new line will be filled.
    Controls in the same line will be resized to fill line width in the same proportion.


    Item types and definition:
    Header (stylized label):
        [ 0@Type("HEADER"), 1@Title, 2(optional)@Attributes, 3(optional)@Events ]
    Text label:
        [ 0@Type("LABEL"), 1@Title, 2(optional)@Attributes, 3(optional)@Events ]
    Text input:
        [ 0@Type("INPUT"), 1@DefaultText, 2(optional)@Attributes, 3(optional)@Events ]
    Checkbox (left or right-aligned)
        [ 0@Type("CHECKBOX"), 1@Title, 2(optional)@DefaultState, 3(optional)@Attributes, 4(optional)@Events ]
        [ 0@Type("CHECKBOX_RIGHT"), 1@Title, 2(optional)@DefaultState, 3(optional)@Attributes, 4(optional)@Events ]
    Slider:
        [ 0@Type("SLIDER"), 1@[Min, Max, Step], 2(optional)@DefaultPosition, 3(optional)@Attributes, 4(optional)@Events ]
    Dropdown or horizontal options select:
        [ 0@Type("DROPDOWN"), 1@ListItems, 2(optional)@DefaultSelected, 3(optional)@Attributes, 4(optional)@Events ]
        [ 0@Type("LISTBOX"), 1@ListItems, 2(optional)@DefaultSelected, 3(optional)@Attributes, 4(optional)@Events ]
    Button:
        [ 0@Type("BUTTON"), 1@Title, 2@Callback, 3(optional)@Args, 4(optional)@Attributes, 5(optional)@Events ]
    Icon Button:
        [ 0@Type("BUTTON"), 1@Icon, 2@Callback, 3(optional)@Args, 4(optional)@Attributes, 5(optional)@Events ]
    Line break (used to break current line ):
        ["BR"]

    , where params:
        // Common
        Type (STRING) - "HEADER", "LABEL","BUTTON","DROPDOWN","LISTBOX","CHECKBOX","INPUT","SLIDER"
        Title (STRING) - display text of the element (header, label, checkbox, button)
        Attributes (ARRAY) - (optional) list of extra attributes to be applied
            in format [AttributeName, AttributeValue]. Defaults to [].
            Supported:
              ["font", (STRING)] - name of the font to use. Defaults to 'PuristaLight'.
              ["size", (NUMBER)] - size of the font. Defaults to 0.04.
              ["color", (RGBA ARRAY)] - RGBA color of text. Defaults to [1,1,1,1].
              ["bg", (RGBA ARRAY)] - RGBA color of the control background. Defaults to [0,0,0,0].
              ["h", (NUMBER)] - item hieght (if not set - size will be used).
              ["w", (NUMBER)] - item width (if not set - item width will be calculated depending on item count in line).
              ["tooltip", (STRING)] - tooltip text for control.
              ["tag", (HASHMAP KEY)] - tag name for the control.

        Events (ARRAY) - (optional) list of custom events handlers to be added
              in format [eventName, callbackFunction, callbackArgs].
              Where eventName - see https://community.bistudio.com/wiki/User_Interface_Event_Handlers
              (without 'on' prefix).
              Parameters of the callback function:
                _this # 0 -- event's arguments (see BIKI);
                _this # 1 -- callback arguments;
                _this # 2 - helper function collections (hashMap), see below.

        // Input
        DefaultText (STRING) - (optional) input's pre-filled text. Defaults to "".

        // Checkbox, Checkbox_right
        DefaultState (BOOL) - (optional) default state of the checkbox. Defaults to false;

        // Slider
        [Min, Max, Step] (ARRAY of Numbers) - range min-max and precision (e.g. 0.01 for 2 decimals).
        DefaultPosition (NUMBER) - (optional) slider default position. Defaults to range minimum.

        // Dropdown/Listbox
        ListItems (ARRAY of STRINGS) - list of options display names (e.g. ["A", "B", "C"]).
        listItems (ARRAY of [STRING, ANY]) - altervative syntax - list of name-value
           pairs, where name is a STRING and value of any type (e.g. [["A", true], ["B", false]]).
        DefaultSelected (NUMBER) - (optional) option index selected by default. Defaults to 0.

        // Button
        Callback (CODE) - (optional) callback function to be called on button click event. Defaults to { closeDialog 2 }.
            Parameters:
            _this # 0 - passed args;
            _this # 1 - helper function collections to access specific ShowAdvDialog2 functions;
            _this # 2 - button control;
        Args (ANY) - (optional) arguemnts to be passed into callback function. Defaults to [].

        // Icon button
        Icon (STRING) - path to icon's .paa file.
        Callback (CODE) - see Button.
        Args (ANY) - (optional) see Button.

        Helper function collections (hashMap) may interact with dialog displayed by ShowAdvDialog2 function.
            _values = _collection call ["GetValues"] -- returns an array of current values of the dialog's inputs (listed in the same order as inputs in dialog).
            _valuesMap = _collection call ["GetTaggedValues"] -- return hash map of current values of the dialog's inputs (where key = input tag, and value - current input value).
            _value = _collection call ["GetControlValue", _control] -- returns value of specific control.
            _value = _collection call ["GetValueByTag", _tag] -- returns value of control by given tag.
            Value format depends on input type:
                INPUT:    inputText(String)
                CHECKBOX: isChecked(Bool)
                SLIDER:   [currentPosition(Number), [minRange(Number), maxRange(Number)]]
                DROPDOWN/LISTBOX:
                          [selectedIndex(Number), selectedItemText(String), selectedItemValue(Anything)

            _control = _collection call ["GetByTag", _tag] -- returns control by given tag.

        Examples:
        // Simple dialog
        [
          ["HEADER", "Hint dialog"],
          ["LABEL", "Hint message"],
          ["INPUT", nil, [["tag", "hintInput"]]],
          ["BR"],
          ["BUTTON", "Show hint", {
            params ["_args", "_ctrl", "_fnc"];
            hint (_fnc call ["GetValueByTag", "hintInput"])
          }]
        ] call dzn_fnc_ShowAdvDialog2;

        // Complex example 1
        [
          ["HEADER", "Dynamic Advanced Dialog (v2)"],
          ["LABEL", "Select teleport position"],
          ["DROPDOWN", [
            ["Airfield", [0,0,0]],
            ["Mike-26", [100,100,0]],
            ["Kamino Firing Range", [200,200,0]]
          ], nil, [["tag", "tpOption"]]],
          ["BR"],

          ["LABEL", "Hint"],
          ["INPUT", "", [ ["color", [1,1,0,1]], ["tooltip", "Enter hint message"], ["tag", "hintInput"] ]],
          ["BR"],

          ["BUTTON", "Teleport", {
            params ["_args", _f"];
            (_f call ["GetValueByTag", "tpOption"]) params ["_idx", "_tpText", "_tpPos"];

            hint format ["Teleport to %1 (%2)", _tpText, _tpPos];
            player setPos _tpPos;
          }],
          ["BUTTON", "Show hint", {
            params ["_args", "_f"];
            hint format [
                "Hint message: %1",
                _f call ["GetValueByTag", "hintInput"]
            ];
          }],
          ["BUTTON", "Spawn vehicle", {
            params ["_args"];
            (selectRandom _args) createVehicle position player;
            hint "Spawned!";
          }, ["C_Offroad_01_F", "C_Offroad_02_F"]],
          ["BUTTON", "End mission", { hint "Mission Ends soon (it's not)!"}],
          ["BR"],

          ["LABEL", "Listbox ->"],
          ["LISTBOX", ["Item1", "Item2", "Item3"]],
          ["BR"],

          ["LABEL", "Dropdown ->"],
          ["DROPDOWN", ["Item1", "Item2", "Item3"]],
          ["BR"],

          ["LABEL"],
          ["LABEL"],
          ["BUTTON", "Close"]
        ] call dzn_fnc_ShowAdvDialog2;

        // Complex example 2
        [
          ["HEADER", "Title", nil, [["mouseEnter", { hint (_this # 1); }, "Mouse Enter Event with Args!"]]],
          ["LABEL", "Text"],
          ["INPUT", "Default text", [["tooltip", "This is a tooltip!"]]],
          ["BR"],
          ["CHECKBOX", "This is a checkbox", nil, [["tooltip", "Some explanation about this checkbox"]]],
          ["CHECKBOX_RIGHT", "This is a checkbox too", true],
          ["BR"],
          ["LISTBOX", ["A", "B", "C"],2],
          ["DROPDOWN", [["A", 100], ["B", 200], ["C", 300]], nil, [["tooltip", "Tooltip for dropdown"]]],
          ["BR"],
          ["LABEL", "Stylized text", [["color", [1,1,0,1]], ["size", 0.1]]],
          ["SLIDER", [0,100,0.01], 50, [["tooltip", "Kek lol"]]],
          ["BR"],
          ["BUTTON", "Close"],
          ["BUTTON", "<t align='center'>Do something</t>", { hint str(_this); diag_log _this }, "KEK LOL"]
       ] call dzn_fnc_ShowAdvDialog2

*/

#include "AdvDialog2.h"

disableSerialization;
forceUnicode 0;

if (isNil QFUNC_COLLECTION) then {
    #include "AdvDialog2__Functions.sqf"
};

// Reset dialog vars
_dialog setVariable [P_DIALOG_INPUTS, nil];
_dialog setVariable [P_DIALOG_CONTROLS, nil];

private _dialogAttrs = createHashMapFromArray [
    [A_W, 1],
    [A_H, 1],
    [A_DIALOG_X, 0],
    [A_DIALOG_Y, 0],
    [A_BG, BG_COLOR_RGBA]
];
private _xAspectRatio = safeZoneH / safeZoneW;

private _items = [];
private _linesHeights = [];

// Parse parameters
// ---------------
#define APPLY_ATTRIBUTES \
    if (typename _attrs == "ARRAY") then { { _item set _x; } forEach _attrs; } else { private _defaults = _item; _item = _attrs; _item merge _defaults; }

private ["_itemDescriptor", "_type", "_item", "_customEvents", "_lineHeight", "_itemAttrs"];

_this pushBack [T_BR]; // Add closing item

private _lineNo = 1;
private _itemsCount = count _this;
private _itemsInLine = [];

for "_i" from 0 to _itemsCount do {
    _itemDescriptor = _this # _i;
    _type = toUpper(_itemDescriptor # 0);
    diag_log format ["(ShowAdvDialog2) Parsing item: %1", _itemDescriptor];

    if (_type == T_BR) then {
        _items pushBack _itemsInLine;

        // Calculate width
        private _totalDesiredWidth = 0;
        private _defaultWidthItems = [];

        {
            private _width = _x getOrDefault [A_W, -1];
            if (_width == -1) then {
                _defaultWidthItems pushBack _x;
                continue;
           };
           _totalDesiredWidth = _totalDesiredWidth + _width;
        } forEach _itemsInLine;
        private _defaultWidthItemsCount = count _defaultWidthItems;

        diag_log format ["(ShowAdvDialog2) Parsing: _totalDesiredWidth=%1,Default items=%2", _totalDesiredWidth, count _defaultWidthItems];

        if (_defaultWidthItemsCount > 0) then {
            private _defaultWidth = (1 - _totalDesiredWidth) / count _defaultWidthItems;
            { _x set [A_W, _defaultWidth] } forEach _defaultWidthItems;
        };

        // Calculate height of the line by selecting max height among the items
        _linesHeights pushBack (selectMax (_itemsInLine apply { _x get A_H }));

        { diag_log format ["(ShowAdvDialog2) Parsing: Items in line %1: %2", _lineNo, _itemsInLine]; } forEach _itemsInLine;

        // Reset collection variables
        _itemsInLine = [];
        _lineNo = _lineNo + 1;
        continue;
    };
    if (_type == T_DIALOG) then {
        _itemDescriptor params ["", "_attrs"];
        // Attributes as pair array
        if (typename _attrs == "ARRAY") then {
            { _dialogAttrs set _x } forEach _attrs;
            continue;
        };

        // Attributes as hashMap
        private _default = _dialogAttrs;
        _dialogAttrs = _attrs;
        _dialogAttrs merge _default;
        continue;
    };

    _item = createHashMapFromArray [
        [A_TYPE, _type],
        [A_FONT, TEXT_FONT],
        [A_SIZE, TEXT_FONT_SIZE],
        [A_COLOR, TEXT_COLOR_RGBA],
        [A_BG, NO_BG_COLOR_RGBA],
        [A_TAG, format ["%1_%2", _type, _i]]
     ];
     _customEvents = [];

    switch (_type) do {
        case T_HEADER: {
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
            APPLY_ATTRIBUTES;

            _this insert [_i + 1, [[T_BR]]];
            _itemsCount = _itemsCount + 1;
        };
        case T_LABEL: {
            // [ 0@Type("LABEL"), 1@Title, 2(optional)@Various ]
            _itemDescriptor params [
                "",
                ["_title", ""],
                ["_attrs", []],
                ["_events", []]
            ];
            _item set [A_TITLE, _title];
            _item set [A_EVENTS, _events];
            APPLY_ATTRIBUTES;
        };
        case T_INPUT: {
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
            APPLY_ATTRIBUTES;
        };
        case T_SLIDER: {
            // [ 0@Type("SLIDER"), 1@[@Min,@Max,@Decimal], 2(optional)@Current, 3@(optional)Various ]
            _itemDescriptor params [
                "",
                "_sliderParams",
                ["_defaultPosition", _x # 0],
                ["_attrs", []],
                ["_events", []]
            ];

            _item set [A_SELECTED, _defaultPosition];
            _item set [A_SLIDER_RANGE, _sliderParams];
            _item set [A_BG, ITEM_BG_COLOR_RGBA];
            _item set [A_EVENTS, _events];
            APPLY_ATTRIBUTES;
        };
        case T_CHECKBOX;
        case T_CHECKBOX_RIGHT: {
            // [ 0@Type, 1@Title, 2@Default(optional), 3@(optional)Various ]
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
            APPLY_ATTRIBUTES;
        };
        case T_LISTBOX;
        case T_DROPDOWN: {
            // [ 0@Type("DROPDOWN"), 1@ListItems, 2@(optional)DefaultSelectd, 3@(optional)Various, 4@(optional)Evenets ]
            _itemDescriptor params [
                "",
                "_listItems",
                ["_defaultSelectionIndex", 0],
                ["_attrs", []],
                ["_events", []]
            ];

            // Process input values to be [STRING, ANY] pairs
            private _isTextValuesPairs = typename (_listItems # 0) == "ARRAY";

            private _titles = [];
            private _values = [];

            {
                private _title = _x;
                private _value = _title;
                if (_isTextValuesPairs) then {
                    _title = _x # 0;
                    _value = _x # 1;
                };

                _titles pushBack (if (typename _title == "STRING") then { _title } else { str(_title) });
                _values pushBack _value;
            } forEach _listItems;

            _item set [A_LIST_TITLES, _titles];
            _item set [A_LIST_VALUES, _values];
            _item set [A_SELECTED, _defaultSelectionIndex];
            _item set [A_BG, ITEM_BG_COLOR_RGBA];
            _item set [A_EVENTS, _events];
            APPLY_ATTRIBUTES;
        };
        case T_BUTTON: {
            // [ 0@Type("BUTTON"), 1@Title, 2@Code, 3@Args, 4@(optional)Various ]
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
            APPLY_ATTRIBUTES;
        };
        case T_ICON_BUTTON: {
            // [ 0@Type("ICON_BUTTON"), 1@Icon, 2@Code, 3(optional)@Args, 4(optional)@Attributes, 5(optional)@Events]
            _itemDescriptor params [
                "",
                "_icon",
                "_callback",
                ["_args", []],
                ["_attrs", []],
                ["_events", []]
            ];

            _item set [A_ICON, _icon];
            _item set [A_CALLBACK, _callback];
            _item set [A_CALLBACK_ARGS, _args];
            _item set [A_BG, ITEM_BG_COLOR_RGBA];
            _item set [A_EVENTS, _events];
            APPLY_ATTRIBUTES;

            // Make icon squared
            private _desiredSize = _item get A_SIZE;
            _item set [A_H, _desiredSize];
            _item set [A_W, _desiredSize * _xAspectRatio];
        };
    };

    _item set [
        A_H,
        ((_item get A_SIZE) + LINE_HEIGHT_OFFSET) max (_item getOrDefault [A_H, -1])
    ];
    _itemsInLine pushBack _item;

    diag_log format ["(ShowAdvDialog2) Parsing: Parsed item %1", _item];
};


// Draw
// -----------------
createDialog DIALOG_NAME;
private _dialog = findDisplay DIALOG_ID;

private _dialogX = _dialogAttrs get A_DIALOG_X;
private _dialogY = _dialogAttrs get A_DIALOG_Y;
private _dialogW = _dialogAttrs get A_W;
private _dialogH = _dialogAttrs get A_H;

private _ctrlGroup = _dialog ctrlCreate [RSC_GROUP, -1];
private _background = _dialog ctrlCreate [RSC_BG, -1, _ctrlGroup];

_ctrlGroup ctrlSetPosition [_dialogX + _dialogW/2, 0, 0, 0];
_ctrlGroup ctrlCommit 0;

#define CTRL_IDX _ctrlId
#define CTRL_IDX_INCREMENT CTRL_IDX = CTRL_IDX + 1
#define REGISTER_AS_INPUT \
    CTRL_IDX = CTRL_IDX + 1; \
    _inputs pushBack _ctrl


private _controls = [];
private _inputs = [];
private _taggedControls = createHashMap;
private CTRL_IDX = START_CTRL_ID;
private _yOffset = 0;


{
    private _lineNo = _forEachIndex;
    private _lineControls = [];
    private _lineItems = _x;

    diag_log format ["(ShowAdvDialog2) Draw: Line number = %1, with %2 items", _lineNo, count _lineItems];
    diag_log format ["(ShowAdvDialog2) Draw: Line height: %1", _linesHeights];
    private _lineHeight = _linesHeights # _lineNo;

    private _xOffset = 0;

    {
        diag_log format ["(ShowAdvDialog2) Draw: Adding control to line %1", _lineNo + 1];
        diag_log format ["(ShowAdvDialog2) Draw: Control: %1", _x];

        private _item = _x;
        private _itemType = _item get A_TYPE;
        private _itemWidth = _dialogW * (_item get A_W);
        private _itemHeight = _item get A_H;

        diag_log format ["(ShowAdvDialog2) Draw: Item width=%1", _itemWidth ];

        private _ctrl = controlNull;
        private _defaultPosition = true;
        private _defaultTooltip = true;
        private _defaultEvents = true;

        switch (_itemType) do {
            case T_HEADER: {
                _defaultPosition = false;

                private _iconHeigth = _item get A_SIZE;
                private _iconWidth = _iconHeigth * _xAspectRatio;

                _ctrl = _dialog ctrlCreate [RSC_HEADER, -1, _ctrlGroup];
                _ctrl ctrlSetStructuredText parseText (_item get A_TITLE);

                private _ctrlCloseBtn = _dialog ctrlCreate [RSC_BUTTON_PICTURE, -1, _ctrlGroup];
                _ctrlCloseBtn ctrlSetText PICTURE_CLOSE;

                _ctrl ctrlSetPosition [
                    0, _yOffset,
                    _itemWidth - _iconWidth, _itemHeight - LINE_HEIGHT_OFFSET
                ];
                _ctrlCloseBtn ctrlSetPosition [
                    _itemWidth - _iconWidth, _yOffset,
                    _iconWidth, _iconHeigth
                ];

                _ctrlCloseBtn ctrlAddEventHandler ["ButtonClick", { closeDialog 2 }];
                _ctrlCloseBtn ctrlCommit 0;
            };
            case T_LABEL: {
                _ctrl = _dialog ctrlCreate [RSC_LABEL, -1, _ctrlGroup];
                _ctrl ctrlSetStructuredText parseText (_item get A_TITLE);
            };
            case T_INPUT: {
                _ctrl = _dialog ctrlCreate [RSC_INPUT, CTRL_IDX, _ctrlGroup];
                _ctrl ctrlSetText (_item get A_SELECTED);
                REGISTER_AS_INPUT;
            };
            case T_SLIDER: {
                _defaultTooltip = false;
                _ctrl = _dialog ctrlCreate [RSC_SLIDER, CTRL_IDX, _ctrlGroup];
                (_item get A_SLIDER_RANGE) params ["_rangeMin", "_rangeMax", "_speed"];

                _ctrl sliderSetSpeed [_speed, _speed * 10, _speed];
                _ctrl sliderSetRange [_rangeMin, _rangeMax];
                _ctrl setVariable [P_CONTROL_SLIDER_CUSTOM_TOOLTIP, _item get A_TOOLTIP];
                _ctrl ctrlAddEventHandler [
                    "SliderPosChanged",
                    FUNC_COLLECTION get FUNC_OnSliderChanged
                ];
                _ctrl sliderSetPosition (_item get A_SELECTED);
                FUNC_COLLECTION call [FUNC_OnSliderChanged, [_ctrl, (_item get A_SELECTED)]];

                REGISTER_AS_INPUT;
            };
            case T_CHECKBOX;
            case T_CHECKBOX_RIGHT: {
                _defaultPosition = false;

                _ctrl = _dialog ctrlCreate [RSC_CHECKBOX, CTRL_IDX, _ctrlGroup];
                private _ctrlTitle = _dialog ctrlCreate [RSC_LABEL, -1, _ctrlGroup];

                #define CB_TEXT_OFFSET 0.004
                #define CB_HEIGHT_OFFSET LINE_HEIGHT_OFFSET / 2

                private _cbHeight = _item get A_SIZE;
                private _cbWidth = _cbHeight * _xAspectRatio;
                private _titleWidth = _itemWidth - _cbWidth - CB_TEXT_OFFSET;

                // [ ] Title
                private _cbOffsetX = _xOffset;
                private _titleOffsetX = _xOffset + _cbWidth + CB_TEXT_OFFSET;
                // Title [ ]
                if (_itemType == T_CHECKBOX_RIGHT) then {
                    _cbOffsetX = _xOffset + _titleWidth + CB_TEXT_OFFSET;
                    _titleOffsetX = _xOffset;
                };

                diag_log format [
                    "_cbOffsetX=%1, _yOffset=%2, _cbWidth=%3, _cbHeight=%4",
                    _cbOffsetX, _yOffset + CB_HEIGHT_OFFSET,
                    _cbWidth, _cbHeight
                ];

                _ctrl ctrlSetPosition [
                    _cbOffsetX, _yOffset + CB_HEIGHT_OFFSET,
                    _cbWidth, _cbHeight
                ];
                _ctrlTitle ctrlSetPosition [
                    _titleOffsetX, _yOffset,
                    _titleWidth, _itemHeight
                ];

                _ctrl cbSetChecked (_item get A_SELECTED);
                _ctrl ctrlSetChecked (_item get A_SELECTED);

                _ctrlTitle ctrlSetStructuredText parseText (_item get A_TITLE);
                _ctrlTitle ctrlSetTextColor (_item get A_COLOR);
                _ctrlTitle ctrlSetFont (_item get A_FONT);
                _ctrlTitle ctrlSetFontHeight (_item get A_SIZE);
                _ctrlTitle ctrlSetTooltip (_item getOrDefault [A_TOOLTIP, ""]);

                // Handle click on text to change checkbox state
                _ctrlTitle ctrlAddEventHandler [
                    "MouseButtonUp",
                    FUNC_COLLECTION get FUNC_OnChekboxLabelClicked
                ];
                _ctrlTitle setVariable [P_CONTROL_RELATED_CHECKBOX, _ctrl];

                {
                    _x params ["_eventName", "_eventCallback", "_eventCallbackArgs"];

                    _ctrlTitle setVariable [
                        format ["%1_%2", _eventName, A_CALLBACK],
                        _eventCallback
                    ];
                    _ctrlTitle setVariable [
                        format ["%1_%2", _eventName, A_CALLBACK_ARGS],
                        _eventCallbackArgs
                    ];
                    _ctrlTitle ctrlAddEventHandler [
                        _eventName,
                        FUNC_COLLECTION get FUNC_OnEvent
                    ];
                } forEach (_item get A_EVENTS);

                _ctrlTitle ctrlCommit 0;
                _ctrl ctrlCommit 0;
                REGISTER_AS_INPUT;
            };
            case T_LISTBOX;
            case T_DROPDOWN: {
                _ctrl = _dialog ctrlCreate [
                    [RSC_DROPDOWN, RSC_LISTBOX] select (_itemType == T_LISTBOX),
                    CTRL_IDX,
                    _ctrlGroup
                ];

                private _textColor = _item get A_COLOR;
                {
                    _x params ["_listItemTitle", "_listItemValue"];
                    _ctrl lbAdd _listItemTitle;
                    _ctrl lbSetColor [_forEachIndex, _textColor];
                } forEach (_item get A_LIST_TITLES);

                _ctrl lbSetCurSel (_item get A_SELECTED);
                _ctrl setVariable [A_LIST_VALUES, _item get A_LIST_VALUES];
                diag_log format ["DROPDOWN >> lbSetCurSel = %1", _item get A_SELECTED];
                REGISTER_AS_INPUT;
            };
            case T_BUTTON: {
                _defaultPosition = false;
                _ctrl = _dialog ctrlCreate [RSC_BUTTON, CTRL_IDX, _ctrlGroup];
                _ctrl ctrlSetStructuredText parseText (_item get A_TITLE);

                _ctrl ctrlAddEventHandler [
                    "ButtonClick",
                    FUNC_COLLECTION get FUNC_OnButtonClick
                ];
                _ctrl setVariable [A_CALLBACK, _item get A_CALLBACK];
                _ctrl setVariable [A_CALLBACK_ARGS, _item get A_CALLBACK_ARGS];

                diag_log format ["Button: Callback=%1, CallbackArg=%2", _item get A_CALLBACK, _item get A_CALLBACK_ARGS];

                // Add some room around the button
                diag_log format ["(ShowAdvDialog2) Draw: Button pos - _xOffset=%1, _yOffset=%2, _itemWidth=%3, _itemHeight=%4", _xOffset, _yOffset, _itemWidth, _itemHeight];
                _ctrl ctrlSetPosition [
                    _xOffset + 0.002, _yOffset + 0.002,
                    _itemWidth - 0.004, _itemHeight - 0.004
                ];

                CTRL_IDX_INCREMENT;
            };
            case T_ICON_BUTTON: {
                _defaultPosition = false;

                _ctrl = _dialog ctrlCreate [RSC_BUTTON_PICTURE, CTRL_IDX, _ctrlGroup];
                _ctrl ctrlSetText (_item get A_ICON);

                _ctrl ctrlSetPosition [
                    _xOffset + 0.002, _yOffset + 0.002,
                    _itemWidth - 0.004, _itemHeight - 0.004
                ];

                _ctrl ctrlAddEventHandler [
                    "ButtonClick",
                    FUNC_COLLECTION get FUNC_OnButtonClick
                ];
                _ctrl setVariable [A_CALLBACK, _item get A_CALLBACK];
                _ctrl setVariable [A_CALLBACK_ARGS, _item get A_CALLBACK_ARGS];

                CTRL_IDX_INCREMENT;
            };
        };

        if (_defaultPosition) then {
            diag_log format ["(ShowAdvDialog2) Draw: Default position: _x=%1, _y=%2, _w=%3, _h=%4", _xOffset, _yOffset, _itemWidth, _lineHeight];
            _ctrl ctrlSetPosition [_xOffset, _yOffset, _itemWidth, _itemHeight];
        };
        if (_defaultTooltip) then {
            _ctrl ctrlSetTooltip (_item getOrDefault [A_TOOLTIP, ""]);
        };
        if (_defaultEvents) then {
            {
                _x params ["_eventName", "_eventCallback", "_eventCallbackArgs"];

                diag_log format [
                    "(ShowAdvDialog2) Draw: Adding Events: _eventName=%1, _callback=%2, _args=%3",
                    _eventName, _eventCallback, _eventCallbackArgs
                ];

                _ctrl setVariable [
                    format ["%1_%2", _eventName, A_CALLBACK],
                    _eventCallback
                ];
                _ctrl setVariable [
                    format ["%1_%2", _eventName, A_CALLBACK_ARGS],
                    _eventCallbackArgs
                ];

                _ctrl ctrlAddEventHandler [
                    _eventName,
                    FUNC_COLLECTION get FUNC_OnEvent
                ];
            } forEach (_item get A_EVENTS);
        };

        _ctrl ctrlSetTextColor (_item get A_COLOR);
        _ctrl ctrlSetFont (_item get A_FONT);
        _ctrl ctrlSetFontHeight (_item get A_SIZE);
        _ctrl ctrlSetBackgroundColor (_item get A_BG);

        _ctrl setVariable [A_TYPE, _itemType];
        _ctrl setVariable [A_TAG, _item get A_TAG];

        _taggedControls set [_item get A_TAG, _ctrl];
        _ctrl ctrlCommit 0;

        _xOffset = _xOffset + _itemWidth;
        _lineControls pushBack _ctrl;
    } forEach _lineItems;

    _controls pushBack _lineControls;

    _yOffset = _yOffset + _lineHeight;
} forEach _items;

_dialog setVariable [P_DIALOG_CONTROLS, _controls];
_dialog setVariable [P_DIALOG_INPUTS, _inputs];
_dialog setVariable [P_DIALOG_TAGGED, _taggedControls];

_background ctrlSetBackgroundColor BG_COLOR_RGBA;
_background ctrlSetPosition [
    0, (_linesHeights # 0),
    _dialogW, _yOffset - (_linesHeights # 0)
];
_background ctrlCommit 0;

_ctrlGroup ctrlSetPosition [_dialogX, _dialogY, _dialogW, _dialogH];
_ctrlGroup ctrlCommit DIALOG_SHOW_TIME;

forceUnicode -1;
