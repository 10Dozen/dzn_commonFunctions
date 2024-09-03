
#include "defines.h"

/*
    Remote Component Exec - component that provides remoteExec wrap 
    for component objects, including storing JIP remoteExec messages 
    until component initialization and registration.
*/

private _CallbackFunction = [
    ["#type", "rce_callback_function"],
    ["#create", {
        _this params ["_function", ["_args", []]];
        _self set ["function", _function];
        _self set ["_args", _args];
    }],
    ["executeCallback", {
        _this params ["_result", "_owner"];
        if (_owner == 0) exitWith {};

        private _args = [];
        _args append (_self get "args");
        if (!isNil "_result") then { _args pushBack _result; };

        LOG_ "(RCE_CallbackFunction) Invoking remoteExec with _args: %1", _args EOL;
        _args remoteExec [_self get "function", _owner];
    }]
];

private _CallbackCOB = [
    ["#type", "rce_callback_cob"],
    ["#create", {
        _this params ["_cobName", "_method", ["_args", []]];
        _self set ["cob", _cobName];
        _self set ["method", _method];
        _self set ["_args", _args];
    }],
    ["executeCallback", {
        _this params ["_result", "_owner"];
        if (_owner == 0) exitWith {};
        
        private _args = [];
        _args append (_self get "args");
        if (!isNil "_result") then { _args pushBack _result; };

        LOG_ "(RCE_CallbackCOB) Invoking remoteExec for COB=%1 / Method=%2 with _args: %3", _self get "cob", _self get "method", _args EOL;
        [
            _self get "cob",
            _self get "method",
            _args
        ] remoteExec ["dzn_fnc_receiveRCE", _owner];
    }]
];


// COB Definition
private _cob = createHashMapObject [[
    ["#str", { "RCE_ComponentObject" }],
    [Q(storedCalls), createHashMap],
    [Q(registeredComponents), createHashMap],

    PREP_COB_FUNCTION(registerComponent),
    PREP_COB_FUNCTION(send),
    PREP_COB_FUNCTION(receive),
    PREP_COB_FUNCTION(store),
    PREP_COB_FUNCTION(handleStored),

    [Q(cobCallback), _CallbackCOB],
    [Q(functionCallback), _CallbackFunction]
]];

_cob
