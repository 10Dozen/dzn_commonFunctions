#include "defines.h"

/*
	Initializes multiline variables and buffer

	Params:
	0: _key (STRING) - nodes name.
	1: _indent (NUMBER) - indend of multiline block.
	2: _initLine (STRING) - multiline block starting line (with token)

	Returns:
	nothing
*/

params ["_key", "_indent", "_initLine"];

DBG_1("(fnc_initMultilineBuffer) Params: %1", _this);
private _mode = switch (toArray _initLine # 0) do {
    case ASCII_VERTICAL_LINE: { MULTILINE_MODE_NEWLINES };
    case ASCII_GT: { MULTILINE_MODE_FOLDED };
    case ASCII_CARET: { MULTILINE_MODE_CODE };
};

private _hash = _self get Q(Struct);
_hash set [MULTILINE_KEY_NODE, _key];
_hash set [MULTILINE_VALUE_NODE, []];
_hash set [MULTILINE_INDENT_NODE, INDENT_MULTILINE + _indent];
_hash set [MULTILINE_MODE_NODE, _mode];

DBG_1("(fnc_initMultilineBuffer) Key set to: %1", _hash get MULTILINE_KEY_NODE);
DBG_1("(fnc_initMultilineBuffer) Indent set to: %1", _hash get MULTILINE_INDENT_NODE);
DBG_1("(fnc_initMultilineBuffer) Mode set to: %1", _hash get MULTILINE_MODE_NODE);