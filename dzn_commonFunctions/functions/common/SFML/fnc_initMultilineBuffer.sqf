#include "defines.h"

/*
	Initializes multiline variables and buffer

	Params:
	0: _key (STRING) - nodes name.
	1: _indent (NUMBER) - indend of multiline block.
	2: _initLine (ARRAY of chars) - multiline block starting line (with token)

	Returns:
	nothing
*/

params ["_key", "_indent", "_initLine"];

DBG_1("(fnc_initMultilineBuffer) Params: %1", _this);
private _mode = switch (_initLine # 0) do {
    case ASCII_VERTICAL_LINE: { MULTILINE_MODE_NEWLINES };
    case ASCII_GT: { MULTILINE_MODE_FOLDED };
    case ASCII_CARET: { MULTILINE_MODE_CODE };
};

_self set [Q(MultilineKeyNode), _key];
_self set [Q(MultilineValueArray), []];
_self set [Q(MultilineIndent), INDENT_MULTILINE + _indent];
_self set [Q(MultilineMode), _mode];

DBG_1("(fnc_initMultilineBuffer) Key set to: %1", _key);
DBG_1("(fnc_initMultilineBuffer) Indent set to: %1", INDENT_MULTILINE + _indent);
DBG_1("(fnc_initMultilineBuffer) Mode set to: %1", _mode);