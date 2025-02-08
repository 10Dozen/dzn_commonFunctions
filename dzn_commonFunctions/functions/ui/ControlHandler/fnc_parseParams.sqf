#include "defines.h"

/*
    Parses given control descriptors and create hashMaps with fully qualified control attributes.

    Returns:
        nothing (updates COB.Items hashMap)
*/

private _itemDescriptor = _this;
private _type = toUpperANSI (_itemDescriptor # 0);
DBG_1("Parsing item: %1", _itemDescriptor);

private _item = createHashMapFromArray [
    [A_TYPE, _type],
    [A_FONT, TEXT_FONT],
    [A_SIZE, TEXT_FONT_SIZE],
    [A_COLOR, TEXT_COLOR_RGBA],
    [A_BG, NO_BG_COLOR_RGBA],
    [A_ENABLED, true],
    [A_SHOW, true]
];

DBG_1("Invoking parse function for %1", _type);
[_self, _item, _itemDescriptor] call (_self get Q(Parsers) get _type);

// -- Update attributes after mergin
(_item getOrDefault [A_POS, DEFAULT_POS_SIZE]) params ["_xPos", "_yPos", "_w", "_h"];
_item set [A_X, _xPos, true];
_item set [A_Y, _yPos, true];
_item set [A_W, _w, true];
_item set [A_H, (_item getOrDefault [A_H, _h]) max ((_item get A_SIZE) + LINE_HEIGHT_OFFSET)];


DBG_1("Parsed item %1", _item);

_item