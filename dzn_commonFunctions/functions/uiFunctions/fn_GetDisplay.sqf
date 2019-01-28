/*
 * @Display = @DisplayName call dzn_fnc_GetDisplay
 *
 * Return selected display IDD 
 *      "main" - main game display
 *      "map" - map display
 * 
 * INPUT:
 * 0: STRING - display name
 *
 * OUTPUT: @Display IDD
 * 
 * EXAMPLES:
 *      _display = "main" call dzn_fnc_GetDisplay;
 */

params[["_name", "main"]];

switch toLower(_name) do {
	case "main": { 	(findDisplay 46) };
	case "map": { 	(findDisplay 12) };
}