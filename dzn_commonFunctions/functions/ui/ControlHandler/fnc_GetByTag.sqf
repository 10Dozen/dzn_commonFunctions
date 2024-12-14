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


LOG_ "[GetByTag]: _this=%1", _this EOL;
params ["_display", "_tag", ["_exactMatch", true]];

private _controls = _self get Q(Controls) get str(_display);
if (isNil "_tag" || isNil "_controls") exitWith { 
    LOG_ "[GetByTag] Not defined Tag or Controls" EOL;
    [] 
};
if (_tag == "") exitWith {
    LOG_ "[GetByTag] Return all controls: %1", _controls EOL;
    +_controls
};

// -- If tag in format "MyTag*" - means non-exact search
if (_tag select [-1 + count _tag, 1] == "*") then {
    _exactMatch = false;
    _tag = _tag select [0, -1 + count _tag];    
    LOG_ "[GetByTag] Asteriks pattern found, change to not-exact match, _tag=%1", _tag EOL;
};

private _filtered = [];
if (_exactMatch) exitWith {
    LOG_ "[GetByTag] Exact match for tag=%1", _tag EOL;
    private _ctrl = _self get Q(TaggedControls) get str(_display) get _tag;
    if (!isNil "_ctrl") then {
        _filtered = [_ctrl]
    };

    _filtered
};

LOG_ "[GetByTag] Not-exact match for tag=%1", _tag EOL;
{
    if (_x select [0, count _tag] != _tag) then { continue; };
    _filtered pushBack _y;
} forEach (_self get Q(TaggedControls) get str(_display));

LOG_ "[GetByTag] Result=%1", _filtered EOL;
_filtered