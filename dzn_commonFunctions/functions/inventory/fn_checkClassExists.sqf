/*
 * @Exists? = [@Classname, @ConfigPath] call dzn_fnc_checkClassExists
 * Checks that given classname is present on given config path.
 *
 * INPUT:
 * 0: STRING - classname to check.
 * 1: ARRAY - path of the config nodes, e.g. ["CfgVehicles"] or ["CfgMyStuff", "Class1", "SubClass"]. Optional, default ["CfgVehicles"].
 * OUTPUT: BOOLEAN (true if class found)
 *
 * EXAMPLES:
 *      _classExists = ["O_soldier"] call dzn_fnc_checkClassExists; // false
 */

params ["_classname", ["_configPath", ["CfgVehicles"]]];

private _config = configFile;
private _result = true;
{
    _config = _config >> _x;
    if (!isClass (_config)) exitWith { _result = false; };
} forEach _configPath + [_classname];

_result
