#include "defines.h"

/*
    Returns HashMap of the inputs current values, where keys are tags of the controls
    (user-defined or auto-generated).

    Params:
        nothing

    Returns:
        HashMap (value fo the tagged input, or NIL if not found)

*/

LOG_ "[GetTaggedValues] Invoked" EOL;

private _dialog = _self get Q(Dialog);
if (isNil "_dialog" || isNull _dialog) exitWith {
    LOG_ "[GetTaggedValues] No dialog found" EOL;
};

private _result = createHashMap;
{
    private _tag = _x getVariable Q(tag);
    LOG_ "[GetTaggedValues] Control=%1, tag=%2", _x, _tag EOL;
    _result set [_tag, _self call [F(getControlValue), _x]];
} forEach (_dialog getVariable Q(Inputs));

LOG_ "[GetTaggedValues] _result=%1", _result EOL;
_result
