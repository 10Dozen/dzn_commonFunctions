/*
 *	Spawn artillery shell of given type over the position in given heigth with given vertical speed.
 *	@ShellObj = [@Pos2d/3d, @ShellType, @Height, @Velocity] call dzn_fnc_spawnShell
 *
 *
 	"Sh_82mm_AMOS"
	,"Smoke_82mm_AMOS_White"
	,"Flare_82mm_AMOS_White"
*/

params ["_pos", ["_type", "Sh_82mm_AMOS"], ["_h", 500], ["_v", -100]];

_pos set [2, _h]; // handle pos2d

private _shell = _type createVehicle _pos;
_shell setVectorDirandUp [[0,0,-1],[0.1,0.1,1]]; 
_shell setVelocity [0, 0, _v];

// handle flare shells
/*
	Velocity of flare is -4.42868
	
	[ [0,1,2,3,4,_shell], "mortar"/"howitzer"] call dzn_fnc_flares_setFlareEffectGlobal 

*/

_shell
