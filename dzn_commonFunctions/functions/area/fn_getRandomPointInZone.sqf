/*
	@Pos = @Array of locations/triggers call dzn_fnc_getRandomPointInZone

	Return random position ATL inside given location/trigger or locations/triggers
	INPUT:
		0: ARRAY	- locations to find
	OUTPUT:	ARRAY Pos3d (ATL)
*/

private _locs = _this;

private _pos = selectRandom (_locs apply {
    _x call BIS_fnc_randomPosTrigger
});

[
    _pos # 0,
    _pos # 1,
    0
]
