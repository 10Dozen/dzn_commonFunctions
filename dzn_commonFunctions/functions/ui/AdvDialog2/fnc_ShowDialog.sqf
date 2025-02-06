#include "defines.h"

/*
    Shows dialog of given structure.

    Params:
        0...n: _itemDescription (Array) - describes control and it's attributes:


    Returns:
        nothing - shows dialog
*/

forceUnicode 0;

// Resets COB state
_self call [F(reset)];

// Set Descriptors
_self set [Q(Descriptors), _this];

// Parse descriptors
_self call [F(parseParams)];

// Render parsed descriptors
_self call [F(render)];

// CBA Event
private _cbaEvents = _self get Q(CBAEvents);
{
    _x params ["_eventName", "_callback", "_args"];
    private _id = [_eventName, _callback, [_self, _args]] call CBA_fnc_addEventHandlerArgs;
    _x pushBack _id;
} forEach _cbaEvents;

// Handle deletion of CBA handlers in case user presses Esc
[
    { !dialog },
    {
        {
            _x params ["_eventName", "", "", "_eventId"];
            [_eventName, _eventId] call CBA_fnc_removeEventHandler;
        } forEach _this;
    },
    _cbaEvents
] call CBA_fnc_waitUntilAndExecute;

forceUnicode -1;