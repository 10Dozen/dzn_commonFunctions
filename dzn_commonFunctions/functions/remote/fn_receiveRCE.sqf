/*
 * Receives RemoteComponentExec call (basically function that remotely executed by dzn_fnc_RCE).
 *
 * INPUT:
 * 0: STRING - name of the component - which COB should be called.
 * 1: STRING -  full name of the COB method (like "fnc_someMethod")
 * 2: ARRAY - optional list of arguments to be passed with method. Defaults to [].
 * 3: HASHMAPOBJECT - optional callback information hashmap object
 *                    (created by dzn_fnc_createRCECallback function).
 * 
 * OUTPUT: NULL
 */

#include "RCE\defines.h"
#define RCE_COB COB

LOG_ "(fn_receiveRCE) Params: %1", _this EOL;

LOG_ "(fn_receiveRCE) _isRemoteExecuted=%1", isRemoteExecuted EOL;
LOG_ "(fn_receiveRCE) remoeExecOwnerActual=%1", remoteExecutedOwner EOL;

if (isNil Q(RCE_COB)) then {
    LOG_ "(fn_receiveRCE) Init RCE component" EOL;
    RCE_COB = [] call COMPILE_SCRIPT(ComponentObject);
};

LOG_ "(fn_receiveRCE) Invoke RCE component - method 'Receive'" EOL;
RCE_COB call [F(receive), _this];
