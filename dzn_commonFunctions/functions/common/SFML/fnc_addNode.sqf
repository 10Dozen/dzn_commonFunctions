#include "defines.h"

/*
	Adds new node and makes it active

	Params:
	0: _key (STRING) - nodes name.

	Returns:
	nothing
*/

params ["_key"];

DBG_1("(addNode) Adding node: %1", _key);
private _node = _self call [F(getNode), []];

DBG_1("(addNode) Node exists?: %1", !isNil {_node get _key});
if (!isNil {_node get _key}) then {
    REPORT_ERROR(ERR_NODE_DUPLICATE, _forEachIndex, "Duplicate node found!");
};

_node set [_key, createHashMap];
_hashNodesRoute pushBack _key;
DBG_1("(addNode) Nodes now: %1", _hashNodesRoute);
