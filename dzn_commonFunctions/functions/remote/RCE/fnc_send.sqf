#include "defines.h"

/*
 * Makes remoteExec call to remote COB.
 *
 * If _callback hashMap object passed -- callback with target = remoteExecutedOwner will be executed in return.
 * See https://community.bistudio.com/wiki/remoteExec for overall description of targets and JIP flag.
 * 
 * INPUT:
 * 0: STRING - name of the registered component.
 * 1: STRING - name of the Component's method.
 * 2: ANY - optional, arguments to method call. Defaults to [].
 * 3: NUMBER - optional, targets (see https://community.bistudio.com/wiki/remoteExec). 
               E.g. 0 - all, 2 - server only, -2 - all except server. Defaults to 0 (all).
 * 4: BOOL - optional, is call JIP-queued. Optional, default to false.
 * 5: HASHMAP - optional, remote exec callback hashmap object
                (declared by dzn_RCE_CallbackFunction or dzn_RCE_RemoteExecCallbackCOB).
 * 
 * OUTPUT: NULL
 * 
 * EXAMPLES:
 *   dzn_RCE call ["fnc_send", ["tSF_CrewOptions", "fnc_assignActions", _args, 0]];
 */

params ["_componentName", "_methodName", ["_args", []], ["_targets", 0], ["_jip", false], ["_callback", nil]];

LOG_ "(send) Params: %1", _this EOL;

private _payload = [_componentName, _methodName, _args];
if (!isNil "_callback") then { _payload pushBack _callback; };

LOG_ "(Send) _payload=%1", _payload EOL;
LOG_ "(Send) _targets=%1, _jip=%2", _targets, _jip EOL;

private _reId = _payload remoteExec ["dzn_fnc_receiveRCE", _targets, _jip];
LOG_ "(Send) _reId=%1", _reId EOL;
