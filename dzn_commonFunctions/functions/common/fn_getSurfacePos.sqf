/*
    Return position at the most top surface at given 2D/3D position or object.
    If _onMostTop flag is set to true (default) - selects position on most
    top surface from given _heightFrom.
    Otherwise for Pos3d and Object - checks for surface position below given position.

    EXAMPLE: [getPosASL player] call dzn_fnc_getSurfacePos
    INPUT:
        0: Pos2d/Pos3d/Object - Position or object
        1: Boolean - optional. Flag to get position on most top surface at given pos. Defaults to true.
        2: Number  - optional, height to measure from. Defaults to 3000.
    OUTPUT: ARRAY Pos3d (ASL)
*/

params ["_origin", ["_onMostTop", true], ["_heightFrom", 3000]];

#define HEIGHT_LOWEST -3000

private _posFrom = _origin;
private _ignoreObject = objNull;

if (_origin isEqualType objNull) then {
    _ignoreObject = _origin;
    _posFrom = getPosASL _origin;
} else {
    if (count _origin == 2) then {
        _posFrom pushBack _heightFrom;
    };
};

if (_onMostTop) then {
    _posFrom set [2, _heightFrom];
};

private _posTo = [
    _posFrom # 0,
    _posFrom # 1,
    HEIGHT_LOWEST
];


private _intersectsWith = lineIntersectsSurfaces [
    _posFrom, _posTo,
    _ignoreObject, objNull,
    true, 1,
    "GEOM", "FIRE"
];

if (_intersectsWith isEqualTo []) exitWith {
    [_posFrom # 0, _posFrom # 1, 0]
};

(_intersectsWith # 0 # 0)
