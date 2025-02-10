
#include "defines.h"

/*
    
*/


// COB Definition
private _cob = createHashMapObject [[
    ["#str", { "SFML_ComponentObject" }],
    
    [Q(Args), []], // Parsing arguments 
    [Q(DataMode), nil],  // Data parsing mode - normal, preprocessed or oneliner

    [Q(Struct), createHashMap],  // Resulting structure of parsed data 

    [Q(CurrentNodesRoute), []],  // Current position of the parser in resulting Struct
    [Q(ArrayNodes), []],
    
    [Q(HasReferenes), false],

    [Q(StrLines), []],
    [Q(CharsLines), []],


    [Q(LineNo), 0], 
    [Q(LineMode), MODE_ROOT], 
    [Q(LineStr), ""],
    [Q(LineChars), []],


    [Q(MultilineMode), nil],
    [Q(MultilineKeyNode), nil],
    [Q(MultilineValueArray), nil],
    [Q(MultilineIndent), nil],




    PREP_COB_FUNCTION(Parse),

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
    PREP_COB_FUNCTION(reset),

    [Q(Sides), createHashMapFromArray [
        [toArray "blufor", west],
        [toArray "BLUFOR", blufor],
        [toArray "west", west],
        [toArray "WEST", west],

        [toArray "opfor", east],
        [toArray "OPFOR", opfor],
        [toArray "east", east],
        [toArray "EAST", east],

        [toArray "indep", independent],
        [toArray "INDEP", independent],
        [toArray "independent", independent],
        [toArray "resistance", resistance],
        [toArray "guer", resistance],
        [toArray "GUER", resistance],

        [toArray "civilian", civilian],
        [toArray "CIVILIAN", civilian],
        [toArray "civ", civilian]
        [toArray "CIV", civilian]
    ]],

    [Q(NullTypes), createHashMapFromArray [
        [toArray "objNull", objNull],
        [toArray "grpNull", grpNull],
        [toArray "controlNull", controlNull],
        [toArray "displayNull", displayNull],
        [toArray "locationNull", locationNull],
        [toArray "taskNull", taskNull],
        [toArray "scriptNull", scriptNull],
        [toArray "configNull", configNull],
        [toArray "diaryRecordNull", diaryRecordNull],
        [toArray "teamMemberNull", teamMemberNull]
    ]],

    [Q(BracketsOpenCloseMap), createHashMapFromArray [
        [ASCII_PARENTHESES_OPEN, ASCII_PARENTHESES_CLOSE],
        [ASCII_CURLY_BRACKET_OPEN, ASCII_CURLY_BRACKET_CLOSE],
        [ASCII_SQUARE_BRACKET_OPEN, ASCII_SQUARE_BRACKET_CLOSE]
    ]]
]];

_cob
