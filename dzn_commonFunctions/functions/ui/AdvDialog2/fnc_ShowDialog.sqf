#include "defines.h"

/*
    Shows dialog of given structure.

    Params:
        0...n: _itemDescription (Array) - describes control and it's attributes:


    Returns:
        nothing - shows dialog
*/

// Resets COB state
_self call [F(reset)];

// Set Descriptors
_self set [Q(Descriptors), _this];

// Parse descriptors
_self call [F(parseParams)];

// Render parsed descriptors
_self call [F(render)];
