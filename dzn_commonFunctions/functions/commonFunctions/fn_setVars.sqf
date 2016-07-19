/*
 * [ @Object, [ [@Varname, @Value, @Global], ... ], @Override ] call dzn_fnc_setVars dzn_fnc_setVars
 * Apply a list of variables to given object. If @Override = false - doesn't update existing variables.
 * 
 * INPUT:
 * 0: OBJECT - Object to apply variables
 * 1: ARRAY - array of variables to apply in format [[@Varname(STRING), @Value(ANY), @Global(BOOL)]], e.g. [["name", "John Doe", false]]
 * 2: BOOL - (optional) force override variable. True if not passed - overrides existing variable, false - do not override.
 * OUTPUT: NULL
 * 
 * EXAMPLES:
 *      [player, [ ["currentWeapon", primaryWeapon player, false], ["currentUniform", uniform player, false] ], true] call dzn_fnc_setVars
 */
 
 
