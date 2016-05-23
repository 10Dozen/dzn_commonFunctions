/*
	[ 
		@DialogStructuredText(lines in array)
		, @Position_Template or @Array of XY
		, @DialogWidth(Chars)
		, @BG_Color
	] call dzn_fnc_ShowMessage;
	
	["Hello Kitty"] call dzn_fnc_ShowMessage;
*/

disableSerialization;
#define BG_COLOR					[0,0,0,0.6]
params [
	"_paramText"
	, ["_paramPosition", "TOP"]
	, ["_paramWidth", 74]
	, ["_paramColor", BG_COLOR]
];

if (typename _paramText == "STRING") then { _paramText = [_paramText]; };
private _dialogOffsetX = 1;
private _dialogOffsetY = 1;
if (typename _paramPosition == "STRING") then {
	_dialogPosition = switch (toUpper(_paramPosition)) do {		
		case "TOP": {
			_dialogOffsetX = 1;
			_dialogOffsetY = 1;
		};
		case "MIDDLE": {};
		case "BOTTOM": {};
		case "HINT": {};		
	};
} else {
	_dialogOffsetX = _paramPosition select 0;
	_dialogOffsetY = _paramPosition select 1;
};

missionNamespace setVariable [
	'dzn_Message_Params'
	, [
		_paramText
		, [_dialogOffsetX, _dialogOffsetY]
		, [_paramWidth, ceil( ( 38.5 / 74 ) * _paramWidth )] 
		, _paramColor
	]
];


KK_fnc_inString = {
    /*
    Author: Killzone_Kid
    
    Description:
    Find a string within a string (case insensitive)
    
    Parameter(s):
    _this select 0: <string> string to be found
    _this select 1: <string> string to search in
    
    Returns:
    Boolean (true when string is found)
    
    How to use:
    _found = ["needle", "Needle in Haystack"] call KK_fnc_inString;
    */

    private ["_needle","_haystack","_needleLen","_hay","_found"];
    _needle = [_this, 0, "", [""]] call BIS_fnc_param;
    _haystack = toArray ([_this, 1, "", [""]] call BIS_fnc_param);
    _needleLen = count toArray _needle;
    _hay = +_haystack;
    _hay resize _needleLen;
    _found = false;
    for "_i" from _needleLen to count _haystack do {
        if (toString _hay == _needle) exitWith {_found = true};
        _hay set [_needleLen, _haystack select _i];
        _hay set [0, "x"];
        _hay = _hay - ["x"]
    };
    _found
};

dzn_fnc_dynamic_message_onLoad = {
	private _displayText = (missionNamespace getVariable 'dzn_Message_Params') select 0;
	private _displayOfsetX = (missionNamespace getVariable 'dzn_Message_Params') select 1 select 0; 
	private _displayOfsetY = (missionNamespace getVariable 'dzn_Message_Params') select 1 select 1; 
	private _displayWidthParam = (missionNamespace getVariable 'dzn_Message_Params') select 2 select 0; 
	private _displayWidth = (missionNamespace getVariable 'dzn_Message_Params') select 2 select 1; 	
	private _displayColor = (missionNamespace getVariable 'dzn_Message_Params') select 3; 
	
	// Define some constants for us to use when laying things out.
	#define GUI_GRID_X		(0)
	#define GUI_GRID_Y		(0)
	#define GUI_GRID_W		(0.025)
	#define GUI_GRID_H		(0.04)
	#define GUI_GRID_WAbs		(1)
	#define GUI_GRID_HAbs		(1)

	#define BASE_IDC			(-1)

	#define BG_X			(_displayOfsetX * GUI_GRID_W + GUI_GRID_X)
	#define BG_Y			(_displayOfsetY * GUI_GRID_H + GUI_GRID_Y)
	#define BG_WIDTH			(_displayWidth * GUI_GRID_W)

	private _dialog = _this select 0;	
	private _background = _dialog ctrlCreate ["IGUIBack", -1];	
	_background ctrlSetPosition [BG_X, BG_Y, BG_WIDTH, 10 * GUI_GRID_H];
	_background ctrlCommit 0;
	
	// Start placing controls 1 units down in the window.
	private _yCoord = BG_Y + (0.5 * GUI_GRID_H);
	private _controlCount = 2;

	#define TITLE_WIDTH			((_displayWidth - 2) * GUI_GRID_W)
	#define TITLE_HEIGHT			(1 * GUI_GRID_H)
	#define TITLE_COLUMN_X			(2 * GUI_GRID_W + GUI_GRID_X)

	// Create the label
	private _isStringText = typename _displayText == "STRING";
	
	private _lineNumbers = 0;
	if (_isStringText) then {
		for "_i" from 0 to count(_displayText) do {
			private _lineToCheck = _displayText select [_i,6];
			if ( ["<br />", _lineToCheck] call KK_fnc_inString || { ["<br/>", _lineToCheck] call KK_fnc_inString } ) then {
				_lineNumbers = _lineNumbers + 1;
			};		
		};
	};
	
	private _displayTextLength = if (_isStringText) then { count _displayText } else { count (str _displayText) };
	private _labelCalculatedRowsHeight = TITLE_HEIGHT * ( ceil ( _displayTextLength / _displayWidthParam ) + _lineNumbers );
	private _labelControl = _dialog ctrlCreate ["RscStructuredText", BASE_IDC + _controlCount];
	
	_labelControl ctrlSetPosition [TITLE_COLUMN_X, _yCoord, TITLE_WIDTH, _labelCalculatedRowsHeight];
	_labelControl ctrlSetFont "PuristaLight";
	_labelControl ctrlSetStructuredText (if (_isStringText) then { parseText _displayText } else { _displayText });
	_labelControl ctrlCommit 0;
	
	_yCoord = _yCoord + _labelCalculatedRowsHeight + (0.5 * GUI_GRID_H);
	_controlCount = _controlCount + 1;

	// Resize the background to fit
	private _backgroundHeight = (1 * GUI_GRID_H) + _labelCalculatedRowsHeight;
	_background ctrlSetPosition [BG_X, BG_Y, BG_WIDTH, _backgroundHeight];
	_background ctrlSetBackgroundColor _displayColor;
	_background ctrlCommit 0;
};

1000 cutRsc ["dzn_Dynamic_Message","PLAIN"];
