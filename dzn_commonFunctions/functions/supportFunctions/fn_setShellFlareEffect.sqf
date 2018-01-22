/*
 * [@Shell, @FlareSettings, @IsMortar] call dzn_fnc_setShellFlareEffect
 * Attach lightsource and flare star to object for given shell locally on client.
 * 
 * INPUT:
 * 0: OBJECT - Shell object
 * 1: ARRAY of settings - (optional) List of flare settings (numbers) in format [@Radius, @Intensity, @IntensityDeviation]. Default: [400,25,10]
 * 2: BOOLEAN - (optional) Is a mortar-caliber shell or howitzer (affects illumination star size). Default: true
 * OUTPUT: NONE
 * 
 * EXAMPLES:
 *      [_shell] call dzn_fnc_setShellFlareEffect;
 *      [_shell, [800, 25, 40], false] call dzn_fnc_setShellFlareEffect;
 */
 
params ["_o", ["_flareSettings", [400,25,10]], ["_isMortar", true]];

private _range = _flareSettings select 0;
private _intensity = _flareSettings select 1;
private _deviation = _flareSettings select 2;

waitUntil { velocity _o select 2 < 0 };
waitUntil { sleep 1; getPos _o select 2 < 240 };

private _flareStars = [];
private _flareStar = objNull;
for "_i" from 1 to (if (_isMortar) then { 1 } else { 2 }) do {
	_flareStar = "F_40mm_White" createVehicleLocal [0,0,0];
	_flareStar attachTo [_o, [0,0,0]];
	_flareStars pushBack _flareStar;
};

sleep 3;

private _flare = "#lightpoint" createVehicleLocal (getPosVisual _o);
_flare setLightAmbient [1,1,1];
_flare setLightColor [1,1,1];
_flare setLightIntensity _intensity;
_flare setLightUseFlare true;
_flare setLightAttenuation [_range, 1, 100, 0, 50, (_range - 10)];
_flare setLightDayLight false;
_flare attachTo [_o, [0,0,0]];

private _h = getPos _o select 2;
_range = _range / 2 / 240;
while { _h > 1  } do {
	sleep ((random 0.01) + 0.05);
	_flare setLightIntensity (_intensity + random (_intensity*_deviation/100));
	_flare setLightAttenuation [2.5*_h*_range, 1, 0, 4.31918e-005, 50, 2.5*_h*_range + 50];
		_h = getPos _o select 2;
	if (_h <= 1) exitWith { deleteVehicle _flare; };
};

{ deleteVehicle _x } forEach _flareStars;
deleteVehicle _flare;
