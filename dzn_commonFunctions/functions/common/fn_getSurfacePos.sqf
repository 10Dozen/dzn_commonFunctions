/*
    Return position at the most top surface at given 2D position.

    EXAMPLE: [getPos player, 270, 1000] call dzn_fnc_getSurfacePos
    INPUT:
        0: Pos3d        - StartPos
        1: Number       - Direction from start pos
        2: Number       - Distance from start pos
    OUTPUT: ARRAY Pos3d
*/

params ["_origin", ["_defaultHeight", 3000]];

#define HEIGHT_LOWEST -3000

private _posFrom = _origin;
private _ignoreObject = objNull;
if (_origin isEqualType []) then {
    if (count _origin == 2) then {
        _posFrom pushBack _defaultHeight;
    };
} else {
    _posFrom = getPosASL _origin;
    _ignoreObject = _origin;
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
