#include "defines.h"

params ["_cob"];

// Header
private _typeNames = [ Q(LISTBOX), Q(DROPDOWN) ];

#define NO_COLOR_RGBA [0,0,0,0]
#define DEFAULT_COLOR_RGBA [1,1,1,1]
#define STRINGIFY(VAL) (if (typename VAL == "STRING") then { VAL } else { str(VAL) })

private _parse = {
    LOG_ "[parse.Listbox/Dropdown] Parsing. Params: %1", _this EOL;
    params ["_cob", "_itemAttrs", "_itemDescriptor", ["_ctrl", controlNull], "_idx"];
    // [ 0@Type("DROPDOWN"), 1@ListItems, 2(optional)@DefaultSelectd, 3(optional)@Attrs, 4(optional)@Evenets ]
    if (!isNull _ctrl) then {
        _itemDescriptor params ["_newAttrs", "_newEvents"];
        _itemDescriptor = [
            "",
            _itemAttrs get A_LIST_ITEMS,
            _itemAttrs get A_VALUE,
            _newAttrs,
            _newEvents
        ];
        LOG_ "[parse.Listbox/Dropdown] On modify: %1", _itemDescriptor EOL;
    };

    _itemDescriptor params [
        "_itemType",
        "_listItems",
        ["_defaultSelectionIndex", 0],
        ["_attrs", []],
        ["_events", []]
    ];

    _itemAttrs set [A_LIST_ITEMS, _listItems];
    _itemAttrs set [A_VALUE, _defaultSelectionIndex];
    _itemAttrs set [A_BG, ITEM_BG_COLOR_RGBA];
    _itemAttrs set [A_EVENTS, _events];
    _cob call [F(MergeAttributes), [_itemAttrs, _attrs]];

    // Process input values to be [STRING, ANY] pairs
    // --- list items may be just string or array of Name-Value-Attrs
    private _newListItems = _itemAttrs get A_LIST_ITEMS;
    LOG_ "[parse.Listbox/Dropdown] _newListItems: %1", _newListItems EOL;

    private _isExtendedSyntax = if (_newListItems isNotEqualTo []) then { typename (_newListItems # 0) == "ARRAY" } else { false };
    private _defaultTooltip = _itemAttrs getOrDefault [A_TOOLTIP, ""];

    private _itemsData = [];
    private _values = [];

    // --- Template for default element
    private _defaultElement = createHashMapFromArray [
        [A_TITLE, ""],
        [A_TOOLTIP, _defaultTooltip]
    ];

    private ["_title", "_value", "_listItemAttrs"];
    // --- Loop through given listbox items
    {
        // --- Get item params (simple @Item = @Title)
        _title = _x;
        _value = _title;
        _listItemAttrs = +_defaultElement; // --- Copy template

        // --- Parse extended syntax where @Item = [@Name, @Value, @Attrs]
        if (_isExtendedSyntax) then {
            _x params [
                "_perItemTitle",
                ["_perItemValue", _x # 0],
                ["_perItemAttrs", []]
            ];

            _title = _perItemTitle;
            _value = _perItemValue;
            _cob call [F(MergeAttributes), [_listItemAttrs, _perItemAttrs]]; // --- Append item specific attributes
        };

        _listItemAttrs set [A_TITLE, STRINGIFY(_title)]; // --- Append item specific attributes

        // --- Append ListItem to a list
        _itemsData pushBack _listItemAttrs;
        _values pushBack _value;
    } forEach _newListItems;

    // --- Save composed Items (hashmap objects) to itemAttrs
    _itemAttrs set [A_LIST_ELEMENTS, _itemsData];
    _itemAttrs set [A_LIST_VALUES, _values];
};

private _create = {
    LOG_ "[create.Listbox/Dropdown] Params: %1", _this EOL;
    params ["_cob", "_itemsAttrs", "_dialog", ["_ctrlGroup", controlNull]];
    private _ctrl = _dialog ctrlCreate [
        [RSC_DROPDOWN, RSC_LISTBOX] select ((_itemAttrs get A_TYPE) == Q(LISTBOX)),
        -1,
        _ctrlGroup
    ];

    _ctrl
};


private _render = {
    private _fulfillListbox = {
        params ["_ctrl", "_item"];
        private [
            "_elementColor", "_iconColor",
            "_elementColorActive", "_iconColorActive"
        ];
        
        LOG_ "[render.Listbox] Fulfilling" EOL;  

        private _defaultTextColor = _item getOrDefault [A_COLOR, DEFAULT_COLOR_RGBA];
        {
            LOG_ "(Listbox) %1", _x EOL;
            private _elementColor = _x getOrDefault [A_COLOR, _defaultTextColor];
            _ctrl lbAdd (_x get A_TITLE);
            _ctrl lbSetPicture [_forEachIndex, _x getOrDefault [A_ICON, ""]];

            // Colors
            // All inherits from Element Color
            // - iconColor overwrites for left and right icons
            _elementColor = _x getOrDefault [A_COLOR, _defaultTextColor];
            _iconColor = _x getOrDefault [A_ICON_COLOR, _elementColor];
            _ctrl lbSetColor [_forEachIndex, _elementColor];
            _ctrl lbSetPictureColor [_forEachIndex, _iconColor];

            // Active colors fallbacks to:
        // - elementColorActive -> elementColor
        // - iconColorActive -> colorActive -> iconColor -> elementColor
        _elementColorActive = _x getOrDefault [A_COLOR_ACTIVE, _elementColor];
        _iconColorActive = _x getOrDefault [A_ICON_COLOR_ACTIVE, _x getOrDefault [A_COLOR_ACTIVE, _iconColor]];
        _ctrl lbSetSelectColor [_forEachIndex, _elementColorActive];
        _ctrl lbSetPictureColorSelected [_forEachIndex, _iconColorActive];
        } forEach (_item get A_LIST_ELEMENTS);
    };

    private _fulfillDropdown = {
        params ["_ctrl", "_item"];
        private [
            "_elementColor", "_iconColor", "_textRightColor", "_iconRightColor",
            "_elementColorActive", "_iconColorActive", "_textRightColorActive", "_iconRightColorActive"
        ];

        LOG_ "[render.Dropdown] Fulfilling" EOL;  
        private _defaultTextColor = _item getOrDefault [A_COLOR, DEFAULT_COLOR_RGBA];
        {
            LOG_ "(Dropdown) %1", _x EOL;
            _ctrl lbAdd (_x get A_TITLE);
            _ctrl lbSetTooltip [
                _forEachIndex,
                _x getOrDefault [A_TOOLTIP, _item getOrDefault [A_TOOLTIP, ""]]
            ];
            _ctrl lbSetPicture [_forEachIndex, _x getOrDefault [A_ICON, ""]];
            _ctrl lbSetPictureRight [_forEachIndex, _x getOrDefault [A_ICON_RIGHT, ""]];
            _ctrl lbSetTextRight [_forEachIndex, _x getOrDefault [A_TEXT_RIGHT, ""]];

            // Colors
            // All inherits from Element Color
            // - iconColor overwrites for left and right icons
            // - iconColorRight overwrites for right icon only
            // - textRightColor overwrites for right text only
            _elementColor = _x getOrDefault [A_COLOR, _defaultTextColor];
            _iconColor = _x getOrDefault [A_ICON_COLOR, _elementColor];
            _textRightColor = _x getOrDefault [A_TEXT_RIGHT_COLOR, _elementColor];
            _iconRightColor = _x getOrDefault [A_ICON_RIGHT_COLOR, _iconColor];
            _ctrl lbSetColor [_forEachIndex, _elementColor];
            _ctrl lbSetColorRight [_forEachIndex, _textRightColor];
            _ctrl lbSetPictureColor [_forEachIndex, _iconColor];
            _ctrl lbSetPictureRightColor [_forEachIndex, _iconRightColor];

            // Active colors fallbacks to:
            // - elementColorActive -> elementColor
            // - iconColorActive -> colorActive -> iconColor -> elementColor
            // - iconColorRightActive -> iconColorActive -> colorActive -> iconColor -> elementColor
            // - textRightColorActive -> colorActive -> textRightColor -> elementColor
            _elementColorActive = _x getOrDefault [A_COLOR_ACTIVE, _elementColor];
            _iconColorActive = _x getOrDefault [A_ICON_COLOR_ACTIVE, _x getOrDefault [A_COLOR_ACTIVE, _iconColor]];
            _iconRightColorActive = _x getOrDefault [A_ICON_RIGHT_COLOR_ACTIVE, _iconColorActive];
            _textRightColorActive =_x getOrDefault [A_TEXT_RIGHT_COLOR_ACTIVE, _x getOrDefault [A_COLOR_ACTIVE, _textRightColor]];
            _ctrl lbSetSelectColor [_forEachIndex, _elementColorActive];
            _ctrl lbSetPictureColorSelected [_forEachIndex, _iconColorActive];
            _ctrl lbSetPictureRightColorSelected [_forEachIndex, _iconRightColorActive];
            _ctrl lbSetSelectColorRight [_forEachIndex, _textRightColorActive];
        } forEach (_item get A_LIST_ELEMENTS);
    };

    LOG_ "[render.Listbox/Dropdown] Rendering. Params: %1", _this EOL;    
    params ["_cob", "_ctrl", "_itemAttrs"];

    LOG_ "[render.Listbox/Dropdown] Deleting %1 list items", count (_ctrl getVariable P_LIST_VALUES) EOL;  
    for "_i" from count (_ctrl getVariable P_LIST_VALUES) to 0 step -1 do { _ctrl lbDelete _i; };

    LOG_ "[render.Listbox/Dropdown] Going to populate list" EOL;
    [_ctrl, _itemAttrs] call ([_fulfillDropdown, _fulfillListbox] select ((_itemAttrs get A_TYPE) == Q(LISTBOX)));
    _ctrl setVariable [P_LIST_VALUES, _itemAttrs get A_LIST_VALUES];

    LOG_ "[render.Listbox/Dropdown] Setting overall attributes" EOL;
    SET_COMMON_ATTRIBURES(_ctrl,_itemAttrs);
    SET_EVENT_HANDLERS(_ctrl,_itemAttrs,_cob);
    REGISTER_AS_INPUT;
    
    _ctrl lbSetCurSel (_itemAttrs get A_VALUE);
    _ctrl ctrlSetPosition [
        _itemAttrs get A_X, _itemAttrs get A_Y,
        _itemAttrs get A_W, _itemAttrs get A_H
    ];
    _ctrl ctrlCommit 0;

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _create, _render]];
