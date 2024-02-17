#include "defines.h"

/*
    Parses given control descriptors and create hashMaps with fully qualified control attributes.

    Returns:
        nothing (updates COB.Items hashMap)
*/

LOG_ "[parseParams] Parsing started" EOL;

_self call [F(AppendLinebreak), -2]; // Add closing item

private _descriptors = _self get Q(Descriptors);
private _items = _self get Q(Items);
private _linesHeights = _self get Q(LineHeights);

private ["_itemDescriptor", "_type", "_item", "_customEvents", "_lineHeight", "_itemAttrs"];
private _lineNo = 1;
private _itemsCount = count _this;
private _itemsInLine = [];

for "_i" from 0 to _itemsCount do {
    _itemDescriptor = _descriptors # _i;
    _type = toUpperANSI (_itemDescriptor # 0);
    LOG_ "[parseParams] Parsing item: %1", _itemDescriptor EOL;

    if (_type == Q(BR)) then {
        LOG_ "[parseParams] Libebreak - calculating layout and line width for items in line" EOL;
        if (_itemsInLine isEqualTo []) then { continue; };
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

        LOG_ "[parseParams] _totalDesiredWidth=%1,Default items=%2", _totalDesiredWidth, count _defaultWidthItems EOL;

        if (_defaultWidthItemsCount > 0) then {
            private _defaultWidth = (1 - _totalDesiredWidth) / count _defaultWidthItems;
            { _x set [A_W, _defaultWidth] } forEach _defaultWidthItems;
        };

        // Calculate height of the line by selecting max height among the items
        _linesHeights pushBack (selectMax (_itemsInLine apply { _x get A_H }));

        { LOG_ "[parseParams] Items in line %1 (item %2): %3", _lineNo, _forEachIndex, _x EOL; } forEach _itemsInLine;

        // Reset collection variables
        _itemsInLine = [];
        _lineNo = _lineNo + 1;
        continue;
    };
    if (_type == Q(DIALOG)) then {
        _itemDescriptor params ["", "_attrs"];
        LOG_ "[parseParams] Updating Dialog attributes: %1", _attrs EOL;
        _self call [F(MergeAttributes), [(_self get Q(DialogAttributes)), _attrs]];
        continue;
    };
    if (_type == Q(ONPARSED)) then {
        _itemDescriptor params ["", "_callback", "_args"];
        LOG_ "[parseParams] Set OnParsed script" EOL;
        _self set [F(OnParsed), _callback];
        _self set [Q(OnParsedArgs), _args];
        continue;
    };
    if (_type == Q(ONDRAW)) then {
        _itemDescriptor params ["", "_callback", "_args"];
        LOG_ "[parseParams] Set OnDraw script" EOL;
        _self set [F(OnDraw), _callback];
        _self set [Q(OnDrawArgs), _args];
        continue;
    };

    _item = createHashMapFromArray [
        [A_TYPE, _type],
        [A_FONT, TEXT_FONT],
        [A_SIZE, TEXT_FONT_SIZE],
        [A_COLOR, TEXT_COLOR_RGBA],
        [A_BG, NO_BG_COLOR_RGBA],
        [A_TAG, format ["Untagged_%1", _i]],
        [A_ENABLED, true]
    ];

    LOG_ "[parseParams] Invoking parse function for %1", _type EOL;
    [_self, _item, _itemDescriptor, _i] call (_self get Q(Parsers) get _type);

    _item set [
        A_H,
        ((_item get A_SIZE) + LINE_HEIGHT_OFFSET) max (_item getOrDefault [A_H, -1])
    ];
    _itemsInLine pushBack _item;

    _itemCount = count _descriptors;
    LOG_ "[parseParams] Parsed item %1", _item EOL;
};

LOG_ "[parseParams] Params parsing finished." EOL;
