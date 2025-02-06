#include "defines.h"

/*
    Recursive search through settings hash, find references and link 'em

    Params:
	0: _node -- (HashMap) hashmap to search

    Returns:
    nothing
*/

params ["_node"];
DBG_1("(findAndLinkRefValues) Params: %1", _this);
{
    _self call [F(findRefValues), [_node, _x]];
} forEach (keys _node) - [ERRORS_NODE, SOURCE_NODE];