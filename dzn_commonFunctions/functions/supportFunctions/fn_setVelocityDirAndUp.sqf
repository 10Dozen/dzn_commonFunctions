/*
	[@Object, @Direction, @Angle, @Velocity] call dzn_fnc_setVelocityDirAndUp
*/

params ["_o","_dir","_angle","_vel"];
	
_o setDir _dir;
[_o, _angle, 0] call BIS_fnc_setPitchBank;
_o setVelocityModelSpace [0, _vel, 0];	
