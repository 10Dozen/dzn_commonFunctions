/*
	@MapGrid(String) = @Pos2d/3d call dzn_fnc_getMapGrid
	Return XXXX YYYY string of given position
	OUTPUT: Map Grid String in XXXX YYYY format
*/

private["_mapGrid","_base","_i", "_grid"];

_mapGrid = "";
_offsets = [
	parseNumber(mapGridPosition [0,0,0] select [0,5])
	, parseNumber(mapGridPosition [0,0,0] select [5,5])
];
for "_i" from 0 to 1 do {	
	_grid = str ( round ( ((_this select _i) + (_offsets select _i)) / 10 ) );
	while {count _grid < 4} do { _grid = format ["0%1", _grid]; };		
	_mapGrid = if (_mapGrid == "") then { _grid } else { format ["%1 %2", _mapGrid, _grid] };
};

_mapGrid
