
#include "defines.h"

/*
    Remote Component Exec - component that provides remoteExec wrap
    for component objects, including storing JIP remoteExec messages
    until component initialization and registration.
*/

// COB Definition
private _cob = createHashMapObject [[
    ["#str", { "RCE_ComponentObject" }],
    [Q(storedCalls), createHashMap],
    [Q(registeredComponents), createHashMap],

    PREP_COB_FUNCTION(registerComponent),
    PREP_COB_FUNCTION(send),
    PREP_COB_FUNCTION(receive),
    PREP_COB_FUNCTION(store),
    PREP_COB_FUNCTION(handleStored)
]];

_cob
