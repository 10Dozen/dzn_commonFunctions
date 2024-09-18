/*
 * Creates RCE Callback object.
 * Given args will be appended with result of the original RCE call 
 * (basically returning RCE call result back to initiator).
 *
 * INPUT:
 * 0: STRING - "function" or "RCE".
 * 1: ARRAY - callback arguments.
 *            For "function": [_functionName(STRING), _args(ARRAY)}]
 *            For "rce": [_cobName(STRING), _method(STRING), _args(ARRAY)]
 *            _args is options, defaults to []
 * 
 * OUTPUT: NULL
 * 
 * _callbackObj = ["function", ["dzn_fnc_setWeather", 3]] call dzn_fnc_createRCECallback;
 *
 * _callbackObj = ["RCE", ["tSF_CrewOptions", "fnc_assignActions", []]] call dzn_fnc_createRCECallback
 */

#include "RCE\defines.h"
#define RCE_COB COB

params ["_mode", "_modeArgs"];

LOG_ "(createRCECallback) Params: %1", _this EOL;
if (isNil Q(RCE_COB)) then {
    LOG_ "(createRCECallback) Init RCE component" EOL;
    RCE_COB = [] call COMPILE_SCRIPT(ComponentObject);
};

LOG_ "(createRCECallback) Invoke RCE component - method 'Receive'" EOL;

private _callbackObjType = RCE_COB get (
    [
        Q(cobCallback), 
        Q(functionCallback)
    ] select _mode == "function"
);

private _callbackObj = createHashMapObject [
    _callbackObjType,
    _modeArgs
];

_callbackObj