#include "defines.h"

/*
    Return current active node

    Params:
    0: _nodes (ARRAY) - nodes path. Optional, defaults to parser nodes path

    Returns:
    _key (STRING) - array idx as keyname
*/

params [["_nodes", _self get Q(CurrentNodesRoute)]];

DBG_1("(getCurrentNode) Nodes: %1", _nodes);

private _node = _self get Q(Struct);
{ _node = _node get _x; } forEach _nodes;

_node
