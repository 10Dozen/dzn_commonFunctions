#include "defines.h"

/*
    Returns tagged control by given tag.

    Params:
        _tag (String) - name of the tag.
    Returns:
        _control (Control) - found control; or nil if not found or dialog not exists.
*/


LOG_ "[GetByTag]: _this=%1", _this EOL;

private _dialog = _self get Q(Dialog);

if (isNil "_dialog" || isNull _dialog) exitWith {
    LOG_ "[GetByTag] No dialog found" EOL;
};

LOG_ "[GetByTag] Tagged control: %1", (_dialog getVariable Q(TaggedControls)) EOL;
LOG_ "[GetByTag] Found Control=%1", (_dialog getVariable Q(TaggedControls)) get _this EOL;

(_dialog getVariable Q(TaggedControls)) get _this
