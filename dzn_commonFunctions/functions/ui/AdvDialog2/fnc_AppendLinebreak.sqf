#include "defines.h"
/*
    Appends linebreak item to list of the dialog parameters after given index.

    Params:
        0: _index (Number) - (optional) index to place new Linebreak item.

    Returns:
        nothing (modifies COB.Params list)
*/

LOG_ "[AppendLinebreak] Invoked with params: %1", _this EOL;

(_self get Q(Descriptors)) insert [ _this + 1, [[Q(BR)]] ];
