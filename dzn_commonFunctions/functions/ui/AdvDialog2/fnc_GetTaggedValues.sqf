#include "defines.h"

/*
    Returns HashMap of the inputs current values, where keys are tags of the controls
    (user-defined or auto-generated).

    Params:
        nothing

    Returns:
        HashMap (value fo the tagged input, or NIL if not found)

*/
DBG_1("Params: %1", _this);

private _dialog = _self get Q(Dialog);
if (isNil "_dialog" || isNull _dialog) exitWith {
    DBG("No dialog found");
};

private _result = createHashMap;
{
    private _tag = _x getVariable Q(tag);
    DBG_2("Control=%1, tag=%2", _x, _tag);
    _result set [_tag, _self call [F(getControlValue), _x]];
} forEach (_dialog getVariable Q(Inputs));

DBG_1("_result=%1", _result);

_result
