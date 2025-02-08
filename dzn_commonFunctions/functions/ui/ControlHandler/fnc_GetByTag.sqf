#include "defines.h"

/*
    Returns tagged control by given tag.

    Params:
        _display (Display) - parent display.
        _tag (String) - tagname of the control. "" means ALL controls.
        _exactMatch (bool) - optional, flag to find by exact match. Defaults to true.
    Returns:
        _control (Array) - list of found controls by tag or all controls (if tag="" was given).
*/


DBG_1("Params: %1", _this);
params ["_display", "_tag", ["_exactMatch", true]];

private _controls = _self get Q(Controls) get str(_display);
if (isNil "_tag" || isNil "_controls") exitWith {
    DBG("Not defined Tag or Controls");
    []
};
if (_tag == "") exitWith {
    DBG_1("Return all controls: %1", _controls);
    +_controls
};

// -- If tag in format "MyTag*" - means non-exact search
if (_tag select [-1 + count _tag, 1] == "*") then {
    _exactMatch = false;
    _tag = _tag select [0, -1 + count _tag];
    DBG_1("Asteriks pattern found, change to not-exact match, _tag=%1", _tag);
};

private _filtered = [];
if (_exactMatch) exitWith {
    DBG_1("Exact match for tag=%1", _tag);
    private _ctrl = _self get Q(TaggedControls) get str(_display) get _tag;
    if (!isNil "_ctrl") then {
        _filtered = [_ctrl]
    };

    _filtered
};

DBG_1("Not-exact match for tag=%1", _tag);
{
    if (_x select [0, count _tag] != _tag) then { continue; };
    _filtered pushBack _y;
} forEach (_self get Q(TaggedControls) get str(_display));

DBG_1("Result=%1", _filtered);
_filtered