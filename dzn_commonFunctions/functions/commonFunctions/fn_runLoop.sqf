/*
	[@Args, @Code, @Delay, @ExitCondition] spawn dzn_fnc_runLoop;
*/
params ["_args", "_code", ["_delay", 15], ["_exitOn", { false }]];

if (call _exitOn) exitWith {};

_args spawn _code;
sleep _delay;

_this spawn fn_runLoop;
