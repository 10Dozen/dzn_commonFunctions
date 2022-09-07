/*
 * @Control = [
 * 		@Display
 *		, @Type
 *		, @SizePosition
 *		, @Text
 *		, @BGColor
 * ] call dzn_fnc_CreateControl
 *
 * Creates control in given display and return it IDC
 * 
 * INPUT:
 * 0: DISPLAY - display
 * 1: STRING - control type name ("LABEL", "BUTTON")
 * 2: ARRAY - size and position array [@X, @Y, @Width, @Height]
 * 3: STRING - text to display on label (may be StructuredText)
 * 4: ARRAY - (optional) RGBA array for background color (default [0,0,0,1])
 * OUTPUT: @Control IDC
 * 
 *
 * EXAMPLES:
 *		// Creates label with text over map display
 *      _label = ["map" call dzn_fnc_GetDisplay, "LABEL", [0,0.9,0.9,0.1], "Map title", [0,0,0,1]] call dzn_fnc_CreateControl;
 *
 *		// Creates button over map display
 *		_button = ["map" call dzn_fnc_GetDisplay, "BUTTON", [0.9,0.9,0.1,0.1], "DO IT!", [0,0,0,1]] call dzn_fnc_CreateControl;
 */

params ["_display", "_type", "_position", "_text",  ["_bgColor", [0,0,0,1]]];

with uiNamespace do {
	_type = switch toUpper(_type) do {
		case "LABEL": { "RscStructuredText" };
		case "BUTTON": { "RscButton" };
	};

	private _ctrl = _display ctrlCreate [_type, -1];
	if (_type isEqualTo "RscStructuredText") then {
		_ctrl ctrlSetStructuredText parseText _text;
	} else {
		_ctrl ctrlSetText _text;
	};
	
	_ctrl ctrlSetPosition _position;
	_ctrl ctrlSetBackgroundColor _bgColor;

	_ctrl ctrlCommit 0;

	_ctrl
};