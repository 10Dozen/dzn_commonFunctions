#include "defines.h"

/*
    Invokes user-defined callback for ButtonClick event and passes params:
        0: _cob - COB object to provide access to helper functions;
        1: _args - user-defined args;
        2: _control - control that triggered event.

    Params:
        0: _control - control that triggered event.

    Returns:
        nothing
*/

params ["_control"];
LOG_ "[OnButtonClick] _control=%1, _thisEvent=%2, _userArgs", _control, _thisEvent, _control getVariable A_CALLBACK_ARGS EOL;

[
    _self,
    _control getVariable A_CALLBACK_ARGS,
    _control
] call (_control getVariable A_CALLBACK);
