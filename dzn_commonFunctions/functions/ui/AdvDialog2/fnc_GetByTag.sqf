#include "defines.h"

/*
    Returns tagged control by given tag.

    Params:
        _tag (String) - name of the tag.
    Returns:
        _control (Control) - found control; or nil if not found or dialog not exists.
*/

DBG_1("Params: %1", _this);

private _dialog = _self get Q(Dialog);

if (isNil "_dialog" || isNull _dialog) exitWith {
    DBG("No dialog found");
};

DBG_1("Tagged control: %1", (_dialog getVariable Q(TaggedControls)));
DBG_1("Found Control=%1", (_dialog getVariable Q(TaggedControls)) get _this);

(_dialog getVariable Q(TaggedControls)) get _this
