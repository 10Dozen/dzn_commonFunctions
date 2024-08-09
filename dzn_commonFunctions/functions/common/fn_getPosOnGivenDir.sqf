/*
    Return position on given direction and distance from base point
    EXAMPLE: [getPos player, 270, 1000] call dzn_fnc_getPosOnGivenDir
    INPUT:
        0: Pos3d        - StartPos
        1: Number       - Direction from start pos
        2: Number       - Distance from start pos
    OUTPUT: ARRAY Pos3d
*/

params ["_pos", "_dir", "_dist"];

(_pos getPos [_dist, _dir])
