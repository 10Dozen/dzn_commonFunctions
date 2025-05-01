/*
	[ @BasicPointObject or [@Pos, @Direction], @CompositionArray] call dzn_fnc_setComposition
	EXAMPLE 1:	 [ player, [...] ] call dzn_fnc_setComposition
	EXAMPLE 2:	 [ [1232, 1421, 0], 180], [...] ] call dzn_fnc_setComposition

	0 (OBJECT) or [@Pos3d, @Direction] - basic point (and direction)
	1 (ARRAY) - composition array in format [
		0 @Classname (STRING)
		1 , @DirFromBasePoint (NUMBER) - relative direction from basepoint to object
		2 , @DistanceFromBasepoint (NUMBER) - relative distance from basepoint to object
		3 , @Orientation (NUMBER) - direction of objects
		4 , @Height (NUMBER) - height of objects above the ground level
		5 , @SimalationEnabled (BOOL) - is simulation enabled for object
		6 , @CodeToExecute (CODE) - code to execute, where _this will refer to object
		7 , @StickedToSurface (BOOL) - if true or not given - stick object to surface normal, if false - place like flat
	]
	OUTPUT: List Of Spawned Objects (ARRAY)
*/

params ["_basePointParam","_compositionArray"];

// Basic point and Basic direction
private _bp = [];
private _bd = 0;
private _pos = [];
private _obj = objNull;
private _spawnedObjects = [];

if ((_this # 0) isEqualType []) then {
	_bp = _basePointParam select 0;
	_bd = _basePointParam select 1;
} else {
	_bp = getPos _basePointParam;
	_bd = getDir _basePointParam;
};

{
	_x params [
		"_class", "_dirTo", "_distTo", "_dir", "_height",
		["_simulation", true],
		["_toExec", nil],
		["_stick", true]
	];
	_pos = _bp getPos [_distTo, _dirTo];
	_pos set [2, _height];

	// Spawn object
	_obj = _class createVehicle _pos;
	_obj enableSimulationGlobal false;
	_spawnedObjects pushBack _obj;

	// Place object
	_obj setPosATL _pos;
	_obj setDir (_dir + _bd);
	if (_stick) then {
		_obj setVectorUp (surfaceNormal (getPosATL _obj));
	};

	// Simulation and Custom Code settings
	_obj setVariable ["dzn_simulation", _simulation];
	if (_toExec isEqualType {}) then {
		[_obj, _toExec] spawn {
			(_this select 0) call (_this select 1);
		};
	};
} forEach _compositionArray;

// -- Enable simulation on non-simulated objects
private _simulatedObjects = _spawnedObjects select { _x getVariable "dzn_simulation" };
{
	_x allowDamage false;
	[_x, true] remoteExec ["enableSimulationGlobal",0];
} forEach _simulatedObjects;

// -- Re-enable damage for simulated objects
_simulatedObjects spawn {
	sleep 2;
	{ _x allowDamage true; } forEach _this;
};

// Return Spawned Objects
_spawnedObjects
