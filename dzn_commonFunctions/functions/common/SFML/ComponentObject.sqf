
#include "defines.h"

/*
    
*/


// COB Definition
private _cob = createHashMapObject [[
    ["#str", { "SFML_ComponentObject" }],
    
    
    [Q(DataMode), 0],  // Data parsing mode - normal, preprocessed or oneliner

    [Q(Struct), createHashMap],  // Resulting structure of parsed data 
    [Q(CurrentNodesRoute), []],  // Current position of the parser in resulting Struct


    PREP_COB_FUNCTION(addArrayItem),
    PREP_COB_FUNCTION(getNode),
    PREP_COB_FUNCTION(splitLines),
    PREP_COB_FUNCTION(removeComment),

    PREP_COB_FUNCTION(parseKeyValuePair)
]];

_cob
