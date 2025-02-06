
#include "defines.h"

/*
    
*/


// COB Definition
private _cob = createHashMapObject [[
    ["#str", { "SFML_ComponentObject" }],
    
    
    [Q(DataMode), 0],  // Data parsing mode - normal, preprocessed or oneliner

    [Q(Struct), createHashMap],  // Resulting structure of parsed data 
    [Q(CurrentNodesRoute), []],  // Current position of the parser in resulting Struct

    [Q(StrLines), []],
    [Q(CharsLines), []],

    [Q(LineStr), ""],
    [Q(LineChars), []],

    PREP_COB_FUNCTION(ParseFile),

    PREP_COB_FUNCTION(addSetting),
    PREP_COB_FUNCTION(addArrayItem),
    PREP_COB_FUNCTION(convertToArray), // TBD
    PREP_COB_FUNCTION(findRefValues),
    PREP_COB_FUNCTION(findAndLinkRefValues),
    PREP_COB_FUNCTION(getNode),
    PREP_COB_FUNCTION(linkRefValue),
    PREP_COB_FUNCTION(parseKeyValuePair),
    PREP_COB_FUNCTION(parseLine),
    PREP_COB_FUNCTION(removeComment),
    PREP_COB_FUNCTION(removeEscaping),
    PREP_COB_FUNCTION(splitLines),




    [Q(Sides), createHashMapFromArray [
        ["BLUFOR", west],
        ["WEST", west],
        ["OPFOR", east],
        ["EAST", east],
        ["INDEP", resistance],
        ["INDEPENDENT", resistance],
        ["RESISTANCE", resistance],
        ["GUER", resistance],
        ["CIVILIAN", civilian],
        ["CIV", civilian]
    ]],
    [Q(NullTypes), createHashMapFromArray [
        ["objNull", objNull],
        ["grpNull", grpNull],
        ["controlNull", controlNull],
        ["displayNull", displayNull],
        ["locationNull", locationNull],
        ["taskNull", taskNull],
        ["scriptNull", scriptNull],
        ["configNull", configNull],
        ["diaryRecordNull", diaryRecordNull],
        ["teamMemberNull", teamMemberNull]
    ]]
]];

_cob
