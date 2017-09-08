/*
	@Pos3d = @MapGrid(String) call dzn_fnc_getPosOnMapGrid	
	
	Parse Map Grid (XXXX YYYY) to Pos 3d
	OUTPUT: Pos 3d ATL on 0 height
*/
private _pos = _this splitString " " joinString "";
private _offsets = [
	parseNumber(mapGridPosition [0,0,0] select [0,5])
	, parseNumber(mapGridPosition [0,0,0] select [5,5])
];

[
	parseNumber (_pos select [0,4]) * 10 - (_offsets select 0)
	, parseNumber (_pos select [4,4]) * 10 - (_offsets select 1)
	, 0
]
