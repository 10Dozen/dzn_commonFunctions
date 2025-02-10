#include "defines.h"

/*
    Resets COB variables 

    Params: none

    Returns:
    nothing
*/

_self set [Q(DataMode), nil];
_self set [Q(Struct), nil];
_self set [Q(CurrentNodesRoute), nil];
_self set [Q(HasReferenes), false];


_self set [Q(StrLines), nil];
_self set [Q(CharsLines), nil];

_self set [Q(LineMode), MODE_ROOT];

_self set [Q(LineStr), nil];
_self set [Q(LineChars), nil];
