
/*
 * [@Shell, @FlareSettings, @IsMortar] call dzn_fnc_setShellFlareEffectGlobal
 * Executes Flare effect script for given shell on all clients.
 * 
 * INPUT:
 * 0: OBJECT - Shell object
 * 1: ARRAY of settings - (optional) List of flare settings (numbers) in format [@Radius, @Intensity, @IntensityDeviation]. Default: [400,25,10]
 * 2: BOOLEAN - (optional) Is a mortar-caliber shell or howitzer (affects illumination star size). Default: true
 * OUTPUT: NONE
 * 
 * EXAMPLES:
 *      [_shell] call dzn_fnc_setShellFlareEffectGlobal;
 *      [_shell, [800, 25, 40], false] call dzn_fnc_setShellFlareEffectGlobal;
 */
 
params ["_o", ["_flareSettings", [400,25,10]], ["_isMortar", true]];
private _shell = _this select 0;

if !(_shell isKindOf "FlareCore") exitWith {};
[_this, "dzn_fnc_setShellFlareEffect", true, true] spawn BIS_fnc_MP;
