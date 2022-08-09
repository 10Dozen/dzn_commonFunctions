
/*
    TODO:
    - Enums:

EnumsSection:
    - &enum1
      name: X
      val: 2
    - &enum2
      name: Y
      val: 3

UsingEnum: *enum1

----

EnumsArraySection:
    - name: X
      val: 2
    - name: Y
      val: 3

UsingEnum: *EnumsArraySection > 0

EnumMapSection:
    Config1: [1,2,3]
    Config2: [3,2,3]

UsingEnum: *EnumMapSection > Config1


Radio:
    Default SW DDistance: 5000
    Default LR Distance: 35000
    Noise Distance Coef: 0.8
    Statics Distance Coef: 1.2

Talkers:
    - callsign: Spearhead-1
      unit: spearhead
      range:
          SW: *Radio > Default SW Distance
          LR: *Radio > Default LR Distance
    - callsign: CCP

*/
#define ASCII_MINUS 45
#define ASCII_HASH 35
#define ASCII_BACKSLASH 92
#define ASCII_SLASH 47
#define ASCII_SPACE 32
#define ASCII_DOUBLE_QUOTE 34
#define ASCII_QUOTE 39
#define ASCII_ASTERISK 42
#define ASCII_COMMA 44
#define ASCII_LT 60
#define ASCII_GT 62
#define ASCII_PARENTHESES_OPEN 40
#define ASCII_PARENTHESES_CLOSE 41
#define ASCII_SQUARE_BRACKET_OPEN 91
#define ASCII_SQUARE_BRACKET_CLOSE 93
#define ASCII_CURLY_BRACKET_OPEN 123
#define ASCII_CURLY_BRACKET_CLOSE 125
#define ASCII_GRAVE 96


#define ERRORS_NODE "#ERRORS"
#define SOURCE_NODE "#SOURCE"

#define STRING_QUOTES_ASCII [ASCII_QUOTE, ASCII_DOUBLE_QUOTE]
#define SCALAR_TYPE_REGEX "^[\s\d\.e()\-+*\/%^]*$"
#define CODE_PREFIX ASCII_CURLY_BRACKET_OPEN
#define CODE_POSTIFX ASCII_CURLY_BRACKET_CLOSE
#define ARRAY_PREFIX ASCII_SQUARE_BRACKET_OPEN
#define ARRAY_POSTFIX ASCII_SQUARE_BRACKET_CLOSE
#define HASHMAP_PREFIX ASCII_PARENTHESES_OPEN
#define HASHMAP_POSTFIX ASCII_PARENTHESES_CLOSE
#define VARIABLE_PREFIX ASCII_LT
#define VARIABLE_POSTFIX ASCII_GT
#define EVAL_PERFIX_ASCII ASCII_GRAVE
#define SIDES_MAP [\
    ["BLUFOR", west],\
    ["WEST", west],\
    ["OPFOR", east],\
    ["EAST", east],\
    ["INDEP", resistance],\
    ["INDEPENDENT", resistance],\
    ["RESISTANCE", resistance],\
    ["GUER", resistance],\
    ["CIVILIAN", civilian],\
    ["CIV", civilian] \
]

#define NIL_TYPE "nil"
#define NULL_TYPES [ \
    "objNull",\
    "grpNull",\
    "locationNull"\
]

#define REF_PREFIX ASCII_ASTERISK
#define REF_INFIX ASCII_GT

#define ERR_FILE_EMPTY 10
#define ERR_FILE_NO_CONTENT 11
#define ERR_INDENT_MALFORMED 20
#define ERR_INDENT_UNEXPECTED_ROOT 21
#define ERR_INDENT_UNEXPECTED_NESTED 22
#define ERR_NODE_DUPLICATE 30
#define ERR_DATA_MALFORMED 40
#define ERR_DATA_KEYVALUEPAIR_MALFORMED 41
#define ERR_DATA_VALUE_MALFORMED 42
#define ERR_DATA_NIL_VARIABLE_REF 50
