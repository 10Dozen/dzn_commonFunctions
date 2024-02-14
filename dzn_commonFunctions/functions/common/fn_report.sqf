/*
* [@Outputs, @Message, @MessageArg1, @MessageArg2, ..., @MessageArgN] call dzn_fnc_report;
*
* INPUT:
* 0: STRING - comma-separated list of outputs. Possible values:
*            sideChat, systemChat, hint -- show message via selected channel
*            RPT -- log message via (diag_log text)
*            error -- log message via (BIS_fnc_error)
* 1: STRING - message to show. May have wildcard symbols and will be formatted via (format) command.
* 2+: ANY - arguments for message formatting.
* OUTPUT: nothing
*
* EXAMPLES:
*      ["error, rpt", "Error in argument [%1] definition", _argName] call dzn_fnc_report;
*/


#define OUT_SIDECHAT "SIDECHAT"
#define OUT_SYSTEMCHAT "SYSTEMCHAT"
#define OUT_HINT "HINT"
#define OUT_RPT "RPT"
#define OUT_ERROR "ERROR"

params ["_output", "_msg", "_arg1", "_arg2", "_arg3"];

_output = (toUpper _output) splitString " " joinString "" splitString ",";

private _args = _this select [2, count _this - 1];
if (_msg == "") then {
    private _argsFormat = [];
    { _argsFormat pushBack ["%" + _forEachIndex]; } forEach _args;
    _msg = _argsFormat joinString " ";
};

private _msgFormat = format ([_msg] + _args);

if (OUT_RPT in _output) then {
    diag_log text _msgFormat;
};

if (OUT_ERROR in _output) then {
    [_msgFormat] call BIS_fnc_error;
};

if (OUT_SIDECHAT in _output) then {
    player sideChat _msgFormat;
};

if (OUT_SYSTEMCHAT in _output) then {
    systemChat _msgFormat;
};

if (OUT_HINT in _output) then {
    hint _msgFormat;
};
