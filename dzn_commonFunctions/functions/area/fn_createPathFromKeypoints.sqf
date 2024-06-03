/*
    [@Group, @Array of keypoints, (@Number of points), (@Cycle), (@Timeouts)] call dzn_fnc_createPathFromKeypoints;

    Creates waypoints throu 3 to 6 randomly chosen keypoints. Last will cycle.
    Keypoints may be an objects with "index" variable - points will be selected in next order:
    - for each "index" (from 0 to 998) only one random object will be chosen as keypoint;
    - remaining number of points will be randomly picked from un-indexed keypoints.

    INPUT:
        0: GROUP        - Group which will get waypoints
        1: ARRAY        - Keypoints
        2: NUMBER (Optional)    - Number of how many waypoits should be created from keypoints
        3: BOOL (Optional)  - Is path cycled?
        4: ARRAY (Optional) - [@Min,@Med,@Max] timeouts on waypoints
    OUTPUT: NULL
*/
#define MAX_INDEX 999

params[
    "_grp"
    ,"_keypoints"
    ,["_numberOfPoints", 2 + round(random 4)]
    ,["_cycle", true]
    ,["_timeouts",[5, 20, 40]]
];

private _numberOfKeypoints = count _keypoints;
if (_numberOfKeypoints == 0) exitWith {};

private _keypointsMap = createHashMap;
private _maxKeypointsCount = 0;
{
    private _index = MAX_INDEX;
    if (_x isEqualType objNull) then {
        _index = _x getVariable ["index", MAX_INDEX];
    };

    private _indexed = _keypointsMap getOrDefaultCall [_index, {[]}, true];
    _indexed pushBack _x;
    if (_index == MAX_INDEX) then {
        _maxKeypointsCount = _maxKeypointsCount + 1;
    };
} forEach _keypoints;

private _indexes = keys _keypointsMap;
_indexes sort true;
private _indexesMax = (count _indexes) - 1;

private _maxKeypointsCount = _maxKeypointsCount + _indexesMax;
if (_numberOfPoints > _maxKeypointsCount) then {
    _numberOfPoints = _maxKeypointsCount;
};

private ["_curIdx", "_wp"];
for "_i" from 1 to _numberOfPoints do {
    _curIdx = _indexes # ((_i - 1) min _indexesMax);

    private _pos = (_keypointsMap get _curIdx) call dzn_fnc_selectAndRemove;
    if (_pos isEqualType objNull) then {
        _pos = getPos _pos;
    };

    _wp = _grp addWaypoint [_pos, 0];
    _wp setWaypointTimeout _timeouts;
};

if (_cycle) then {
    _wp = _grp addWaypoint [getPosATL (units _grp select 0), 0];
    _wp setWaypointType "CYCLE";
};

deleteWaypoint [_grp, 0];
