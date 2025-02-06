#include "defines.h"

/*
	Returns expected indent, according to current active node position

	Params:
	0: _key (STRING) - nodes name.

	Returns:
	nothing
*/

DBG_1("(calculateExpectedIndent) Nodes: %1", _hashNodesRoute);
private _expected = 0;
{
    _expected = _expected + ([INDENT_DEFAULT, INDENT_ARRAY_NESTED] select (_x isEqualType 0);
} forEach _hashNodesRoute;

_expected