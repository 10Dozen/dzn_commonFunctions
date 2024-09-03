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
 * [
 *    "tSF_CrewOptions",
 *    "fnc_assignActions",
 *    [_arg1, _arg2],
 *    0
 * ] call dzn_fnc_remoteComponentExec;
 *
 * [
 *    "tSF_Core",
 *    "fnc_getComponentVariable",
 *    ["tSF_Respawn", "locationObjects"],
 *    2,
 *    false,
 *    // -- Callback will send remote exec component request back to the initiator
 *    createHashMapObject [dzn_RCE_RemoteExecCallbackCOB, [
 *       "tSF_Core", "fnc_applyComponentVariable", ["tSF_Respawn", "locationObjects"]
 *    ]]
 * ] call dzn_fnc_RCE;
 */

#include "RCE\defines.h"
#define RCE_COB COB

LOG_ "(RCE) Params: %1", _this EOL;

if (isNil Q(RCE_COB)) then {
    LOG_ "(RCE) Init RCE component" EOL;
    RCE_COB = [] call COMPILE_SCRIPT(ComponentObject);
};

LOG_ "(RCE) Invoke RCE component - method 'Send'" EOL;
RCE_COB call [F(send), _this];
