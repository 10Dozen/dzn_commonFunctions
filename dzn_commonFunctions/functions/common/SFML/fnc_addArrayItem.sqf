#include "defines.h"

/*
	Adds new item to current active array hash node in format [index, value]

	Params:
	0: _item (???) - item to add.

	Returns:
	_key (STRING) - array idx as keyname
*/

params ["_item"];

private _node = _self call ["getNode", []];
private _key = count keys _node;

_node set [
	_key, 
	[_item, nil] select (isNil "_item")	
];

DBG_3("(addArrayItem) Adding array node %1 with item [%2]. Nodes: %3", _key, if (isNil "_item") then { "any" } else { _item }, _hashNodesRoute);

DBG("(addArrayItem) ----------- Add array item to hash node -------------");
DBG_1("(addArrayItem) %1", values _node);
DBG("(addArrayItem) ------------------------------------------------------");

(_key)

/*
// Adds new item to current active array hash node in format [index, value]
params ["_item"];
private _node = _self call ["getNode", []];
private _key = count keys _node;
_node set [_key, if (isNil "_item") then { nil } else { _item }];
DBG_3("(addArrayItem) Adding array node %1 with item [%2]. Nodes: %3", _key, if (isNil "_item") then { "any" } else { _item }, _hashNodesRoute);

DBG("(addArrayItem) ----------- Add array item to hash node -------------");
DBG_1("(addArrayItem) %1", values _node);
DBG("(addArrayItem) ------------------------------------------------------");

(_key)
*/