/*
	@Pos3d = 	[@Pos3d, @Radius, @Height] call dzn_fnc_getRandomPoint;
	@Pos3d = 	[@Trg/Loc, @Height] call dzn_fnc_getRandomPoint
			[ [Trg,Trg,Trg], @Height] call dzn_fnc_getRandomPoint
*/

private _pos = [];
private _hIndex = 0;

if (typename (_this select 0) == "ARRAY") then {
	// Pos3d or Array of triggers
	if (typename (_this select 0 select 0) == "SCALAR") then {
		// [@Pos3d, @Radius, @Height] call dzn_fnc_getRandomPoint;	
		
		_pos = [_this select 0, random 359, _this select 1] call dzn_fnc_getPosOnGivenDir;
		while { _pos call dzn_fnc_isInWater } do {
			_pos = [_this select 0, random 359, _this select 1] call dzn_fnc_getPosOnGivenDir;		
		};
		_hIndex = 2;
		
	}  else {	
		// [ [Trg,Trg,Trg], @Height] call dzn_fnc_getRandomPoint
		
		_pos = (_this select 0) call dzn_fnc_getRandomPointInZone;
		_hIndex = 1;
		
	}
} else {
	// [@Trg/Loc, @Height] call dzn_fnc_getRandomPoint
	
	_pos = [_this select 0] call dzn_fnc_getRandomPointInZone;
	_hIndex = 1;	
	
};

_pos set [2, ( if (!isNil {_this select _hIndex}) then { random (_this select _hIndex) } else { 0 } )];

( _pos )
