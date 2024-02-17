#include "defines.h"

params ["_cob"];

// Header
private _typeNames = [ Q(LISTBOX), Q(DROPDOWN) ];

#define NO_COLOR_RGBA [0,0,0,0]
#define DEFAULT_COLOR_RGBA [1,1,1,1]
#define STRINGIFY(VAL) (if (typename VAL == "STRING") then { VAL } else { str(VAL) })

private _parse = {
    LOG_ "[parse.Listbox/Dropdown] Parsing. Params: %1", _this EOL;
    params ["_cob", "_item", "_itemDescriptor", "_idx"];
    // [ 0@Type("DROPDOWN"), 1@ListItems, 2(optional)@DefaultSelectd, 3(optional)@Attrs, 4(optional)@Evenets ]
    _itemDescriptor params [
        "_itemType",
        "_listItems",
        ["_defaultSelectionIndex", 0],
        ["_attrs", []],
        ["_events", []]
    ];

    _item set [A_SELECTED, _defaultSelectionIndex];
    _item set [A_BG, ITEM_BG_COLOR_RGBA];
    _item set [A_EVENTS, _events];
    PARSING_APPLY_ATTRIBUTES;

    // Process input values to be [STRING, ANY] pairs
    private _isExtendedSyntax = typename (_listItems # 0) == "ARRAY";
    private _defaultTooltip = _item getOrDefault [A_TOOLTIP, ""];

    private _itemsData = [];
    private _values = [];

    private _defaultElement = if (_itemType == Q(LISTBOX)) then {
        createHashMapFromArray [
            [A_TITLE, ""]
        ]
    } else {
        createHashMapFromArray [
            [A_TITLE, ""],
            [A_TOOLTIP, _defaultTooltip]
        ]
    };

    private ["_title", "_value", "_itemAttrs"];

    {
        _title = _x;
        _value = _title;
        _itemAttrs = +_defaultElement;

        if (_isExtendedSyntax) then {
            _x params [
                "_perItemTitle",
                ["_perItemValue", _x # 0],
                ["_perItemAttrs", []]
            ];

            _title = _perItemTitle;
            _value = _perItemValue;
            _cob call [F(MergeAttributes), [_itemAttrs, _perItemAttrs]];
        };

        _itemAttrs set [A_TITLE, STRINGIFY(_title)];

        _itemsData pushBack _itemAttrs;
        _values pushBack _value;
    } forEach _listItems;

    _item set [A_LIST_ELEMENTS, _itemsData];
    _item set [A_LIST_VALUES, _values];
};

private _render = {
    private _fulfillListbox = {
        params ["_ctrl", "_item"];
        private _defaultTextColor = _item getOrDefault [A_COLOR, DEFAULT_COLOR_RGBA];
        {
            LOG_ "(Listbox) %1", _x EOL;

            private _elementColor = _x getOrDefault [A_COLOR, _defaultTextColor];

            _ctrl lbAdd (_x get A_TITLE);
            _ctrl lbSetColor [_forEachIndex, _elementColor];
            _ctrl lbSetPicture [_forEachIndex,
                _x getOrDefault [A_ICON, ""]
            ];
            _ctrl lbSetPictureColor [_forEachIndex,
                _x getOrDefault [A_ICON_COLOR, _elementColor]
            ];
            _ctrl lbSetSelectColor [_forEachIndex,
                _x getOrDefault [A_COLOR_ACTIVE, _elementColor]
            ];
            _ctrl lbSetPictureColorSelected [_forEachIndex,
                _x getOrDefault [A_ICON_COLOR_ACTIVE,
                    _x getOrDefault [A_COLOR_ACTIVE, _elementColor]
               ]
            ];
        } forEach (_item get A_LIST_ELEMENTS);
    };

    private _fulfillDropdown = {
        params ["_ctrl", "_item"];
        private _defaultTextColor = _item getOrDefault [A_COLOR, DEFAULT_COLOR_RGBA];
        {
            LOG_ "(Dropdown) %1", _x EOL;

            private _elementColor = _x getOrDefault [A_COLOR, _defaultTextColor];

            _ctrl lbAdd (_x get A_TITLE);
            _ctrl lbSetTooltip [
                _forEachIndex,
                _x getOrDefault [A_TOOLTIP, _item getOrDefault [A_TOOLTIP, ""]]
            ];
            _ctrl lbSetColor [
                _forEachIndex,
                _elementColor
            ];

            _ctrl lbSetPicture [_forEachIndex, _x getOrDefault [A_ICON, ""]];
            _ctrl lbSetPictureColor [_forEachIndex,
                _x getOrDefault [A_ICON_COLOR, _elementColor]
            ];
            _ctrl lbSetPictureRight [_forEachIndex, _x getOrDefault [A_ICON_RIGHT, ""]];
            _ctrl lbSetPictureRightColor [_forEachIndex,
                _x getOrDefault [A_ICON_RIGHT_COLOR, _x getOrDefault [A_ICON_COLOR, _elementColor]]
            ];
            _ctrl lbSetTextRight [_forEachIndex, _x getOrDefault [A_TEXT_RIGHT, ""]];
            _ctrl lbSetColorRight [
                _forEachIndex,
                _x getOrDefault [A_TEXT_RIGHT_COLOR, _elementColor]
            ];
            _ctrl lbSetSelectColor [
                _forEachIndex,
                _x getOrDefault [A_COLOR_ACTIVE, _elementColor]
            ];
            _ctrl lbSetSelectColorRight [
                _forEachIndex,
                _x getOrDefault [
                    A_COLOR_ACTIVE,
                    _x getOrDefault [A_TEXT_RIGHT_COLOR, _elementColor]
                ]
            ];
        } forEach (_item get A_LIST_ELEMENTS);
    };

    LOG_ "[render.Listbox/Dropdown] Rendering. Params: %1", _this EOL;

    params ["_cob", "_item", "_xOffset", "_yOffset", "_itemWidth", "_itemHeight", "_dialog", "_ctrlGroup"];
    private _itemType = _item get A_TYPE;
    private _ctrl = _dialog ctrlCreate [
        [RSC_DROPDOWN, RSC_LISTBOX] select ((_item get A_TYPE) == Q(LISTBOX)),
        -1,
        _ctrlGroup
    ];

    private _textColor = _item get A_COLOR;
    [_ctrl, _item] call ([_fulfillDropdown, _fulfillListbox] select (_itemType == Q(LISTBOX)));

    _ctrl lbSetCurSel (_item get A_SELECTED);
    _ctrl setVariable [Q(listValues), _item get A_LIST_VALUES];

    LOG_ "[render.Dropdown/Listbox] setting lbSetCurSel = %1", _item get A_SELECTED EOL;

    REGISTER_AS_INPUT;
    SET_POSITION(_ctrl, _xOffset, _yOffset, _itemWidth, _itemHeight);
    SET_ATTRIBURES(_ctrl);

    _ctrl
};

_cob call [F(RegisterControlType), [_typeNames, _parse, _render]];
