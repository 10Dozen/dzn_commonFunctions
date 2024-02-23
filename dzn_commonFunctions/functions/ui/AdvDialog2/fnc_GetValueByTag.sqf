#include "defines.h"

/*
    Returns tagged input value by given tag.

    Params:
        _tag (String) - name of the tag.
    Returns:
        Anything (value fo the tagged input, or NIL if not found)

*/

LOG_ "[GetValueByTag] _this=%1", _this EOL;

_self call [
    F(getControlValue),
    _self call [F(GetByTag), _this]
]
