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
DBG_1("Params: %1", _this);
params ["_button"];

private _dialogComponentObject = _button getVariable Q(DialogCOB);

DBG_4("_control=%1, _thisEvent=%2, _userArgs=%3, _cob=%4", _button, _thisEvent, _button getVariable A_CALLBACK_ARGS, _dialogComponentObject);

[
    _dialogComponentObject,
    _button getVariable A_CALLBACK_ARGS,
    _button
] call (_button getVariable A_CALLBACK);
