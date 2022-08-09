
/*
 * @ShellObj = [@Pos2d/3d, (opt)@ShellType, (opt)@Dispersion, (opt)@IsMortar, (opt)@Height, (opt)@Velocity] call dzn_fnc_spawnShell
 * Spawn artillery shell of given type over the position in given heigth with given vertical speed.
 * 
 * INPUT:
 * 0: POS2D/3D - Position to spawn
 * 1: STRING - (optional) Classname of the artillery round. E.g. "Sh_82mm_AMOS" (default) ,"Smoke_82mm_AMOS_White","Flare_82mm_AMOS_White"
 * 2: NUMBER - (optional) Randomized radius. Default: 10
 * 3: BOOLEAN - (optional) Is a mortar-caliber shell or howitzer (affects illumination round size). Default: true
 * 4: NUMBER - (optional) Spawn altitude in meters. Default: 500
 * 5: NUMBER - (optional) Shell initial vertical velocity. Does not affect illumination rounds. Default: -100
 * OUTPUT: 
 * 
 * EXAMPLES:
 *      _shell = [ getMarkerPos "Arty1" ] call dzn_fnc_spawnShell;
 *      _shell = [ [1200,2200,0], "Smoke_82mm_AMOS_White", 300] call dzn_fnc_spawnShell;
 */

params ["_pos",["_type","Sh_82mm_AMOS"], ["_disp", 10], ["_isMortar", true], ["_h", 500],["_v", -100]];

_pos = _pos getPos [_disp, random 360];
_pos set [2, _h];

private _shell = _type createVehicle _pos;
_shell setVectorDirandUp [[0,0,-1],[0.1,0.1,1]];

if (_type isKindOf "FlareCore") then {
	_shell setPosATL [_pos select 0, _pos select 1, 280];
	[
		_shell
		, if (_isMortar) then {
			[400,25,10]
		} else {
			[600,25,10]
		}
		, _isMortar
	] call dzn_fnc_setShellFlareEffectGlobal;

	_shell setVelocity [0,0,0.1];
	_shell spawn {
		while { (getPosATL _this select 2) > 1 } do {
			_this setVelocity [0,0,-4];
		};
	};
} else {
	_shell setVelocity [0,0,_v];
};

_shell
