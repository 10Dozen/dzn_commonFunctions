#include "defines.h"
/*
    Invokes user-defined callback for specific Event type and passes:
        0: _eventData - original event data;
        1: _cob - COB object to provide access to helper functions.
        2: _args - user-defined args;

    Params:
        0: _ctrl - control that triggered event.

    Returns:
        nothing
*/

LOG_ "[OnEvent] _this=%1", _this EOL;
params ["_ctrl"];
private _eventCallback = _ctrl getVariable format ["%1_%2", _thisEvent, A_CALLBACK];
private _eventCallbackArgs = _ctrl getVariable [
    format ["%1_%2", _thisEvent, A_CALLBACK_ARGS],
    []
];

[
    _this,
    _self,
    _eventCallbackArgs
] call _eventCallback;
