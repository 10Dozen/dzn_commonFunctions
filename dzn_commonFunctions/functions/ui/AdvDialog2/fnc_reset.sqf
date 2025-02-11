#include "defines.h"

/*
    Resets state of the Component object.

    Params:
        none

    Returns:
        nothing
*/

DBG_1("Params: %1", _this);
_self set [Q(Dialog), nil];
_self set [Q(DialogID), ""];
_self set [
    Q(DialogAttributes),
    createHashMapFromArray [
        [A_W, 1],
        [A_H, 1],
        [A_X, 0],
        [A_Y, 0]
    ]
];

_self set [Q(Descriptors), nil];
_self set [Q(Items), []];
_self set [Q(LineHeights), []];

_self set [Q(Controls), []];
_self set [Q(ControlsPerLines), []];

_self set [F(OnParsed), {}];
_self set [F(OnParsedArgs), {}];
_self set [Q(OnDraw), {}];
_self set [Q(OnDrawArgs), {}];

_self set [Q(Closed), false];

_self set [Q(CBAEvents), []];

{
    _x params ["_eventName", "", "", "_eventId"];
    [_eventName, _eventId] call CBA_fnc_removeEventHandler;
} forEach (_self get Q(CBAEvents));
