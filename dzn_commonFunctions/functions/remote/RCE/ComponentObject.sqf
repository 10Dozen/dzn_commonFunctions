
#include "defines.h"

/*
    Remote Component Exec - component that provides remoteExec wrap 
    for component objects, including storing JIP remoteExec messages 
    until component initialization and registration.
*/

dzn_RCE_CallbackFunction = [
    ["#type", "rce_callback_function"],
    ["#create", {
        _this params ["_function", ["_args", []]];
        _self set ["function", _function];
        _self set ["_args", _args];
    }],
    ["executeCallback", {
        if (remoteExecutedOwner == 0) exitWith {};
        private _args = _self get "args";
        if (!isNil "_this") then { _args = _args + [_this] };
        DEBUG_ "(RCE_CallbackFunction) Invoking remoteExec with _args: %1", _args EOL;
        _args remoteExec [_self get "function", remoteExecutedOwner];
    }]
];

dzn_RCE_RemoteExecCallbackCOB = [
    ["#type", "rce_callback_cob"],
    ["#create", {
        _this params ["_cobName", "_method", ["_args", []]];
        _self set ["cob", _cobName];
        _self set ["method", _method];
        _self set ["_args", _args];
    }],
    ["executeCallback", {
        if (remoteExecutedOwner == 0) exitWith {
            DEBUG_ "(RCE_CallbackCOB) Owner is 0, preventing execution..." EOL;
        };
        private _args = _self get "args";
        if (!isNil "_this") then { _args = _args + [_this] };
        DEBUG_ "(RCE_CallbackCOB) Invoking remoteExec for COB=%1 / Method=%2 with _args: %3", _self get "cob", _self get "method", _args EOL;
        [
            _self get "cob",
            [_self get "method", _args]
        ] remoteExec [FUNC(CallComponentByRemote), remoteExecutedOwner];
    }]
];


// COB Definition
private _cob = createHashMapObject [[
    ["#str", { "RCE_ComponentObject" }],
    [Q(queue), createHashMap],
    [Q(registeredComponent), createHashMap],

    PREP_COB_FUNCTION(registerComponent),
    PREP_COB_FUNCTION(send),
    PREP_COB_FUNCTION(receive),
    PREP_COB_FUNCTION(addToQueue),
    PREP_COB_FUNCTION(handleQueue),
    
    ["#create", {}]
]];




_cob
