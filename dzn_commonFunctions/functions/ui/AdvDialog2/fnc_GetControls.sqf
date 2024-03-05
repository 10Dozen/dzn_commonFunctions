#include "defines.h"

/*
    Returns list of the controls in the same order as it was added in initial params.
    Type match is

    Params:
        0: _filterByTag (ARRAY) - filter by tags in list.
        1: _filterByType (ARRAY) - filter by type names in list.
    Returns:
        _controls (Array) - list of controls found or empty list.
*/

LOG_ "[GetControls] Invoked: %1", _this EOL;
params [
    ["_filterByTag", []],
    ["_filterByType", []]
];

private _controls = _self get Q(Dialog) getVariable Q(Controls);

private ["_ctrlIdentifier"];

if (_filterByTag isNotEqualTo []) then {
    _controls = _controls select {
        _ctrlIdentifier = _x getVariable Q(tag);
        (_filterByTag findIf { [_x, _ctrlIdentifier, true] call BIS_fnc_inString }) > -1
    };
};

if (_filterByType isNotEqualTo []) then {
    _controls = _controls select {
        _ctrlIdentifier = _x getVariable Q(type);
        _filterByType findIf { _ctrlIdentifier == _x } > -1
    };
};

_controls
