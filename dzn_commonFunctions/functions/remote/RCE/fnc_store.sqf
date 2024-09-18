#include "defines.h"

/*
    Adds RemoteExec call to queue to be handled later, once Component registers.

    (_self) 
    
    Params:
    _payload (array) - remote exec payload ([_cobName, _methodName, _args, _callback])
    _remoteExecOwner (number) - machine ID of the remoteExec call initiator. Used for callbacks.

    Return: nothing

    Example:
    tSF_Core_Component call ["fnc_RCE_addToQueue", [_parmas, 2]]
*/

params ["_payload", "_remoteExecOwner"];
_payload params ["_cobName"];

LOG_ "(store) Params: %1", _this EOL;

LOG_ "(store) _isRemoteExecuted=%1", isRemoteExecuted EOL;
LOG_ "(store) remoeExecOwnerActual=%1", remoteExecutedOwner EOL;
LOG_ "(store) remoeExecOwnerSaved=%1", _remoteExecOwner EOL;

private _queue = (_self get Q(storedCalls)) getOrDefaultCall [
    toLowerANSI _cobName,
    { [] },
    true
];

// -- Save in format of the fnc_receive params:
//    ["_cobName", "_methodName", "_args", "_callback", "_remoteExecOwner"]
if (count _payload > 3) then {
    _payload append _remoteExecOwner;
} else {
    _payload append [nil, _remoteExecOwner];
};
_queue pushBack _payload;
