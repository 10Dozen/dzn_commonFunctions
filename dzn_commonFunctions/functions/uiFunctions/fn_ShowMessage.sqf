/*
	[ 
		@DialogStructuredText(lines in array)
		, @Position_Template or [@Array of XY, @DialogWidth(Chars)]
		, @BG_Color
		, @Duration or @ConditionToHide
	] call dzn_fnc_ShowMessage;
	
	["Hello Kitty"] call dzn_fnc_ShowMessage;
	[ ["Hello Kitty"] ] call dzn_fnc_ShowMessage;
	[ ["Hello Kitty", "Hello Again", "Hello Kitty-Kitty", "Hello-Hello"] ] call dzn_fnc_ShowMessage;
	[ ["<t color='#AAAAAA' align='left'>Hello Kitty</t>", "Hello Again", "<t color='#AAAAAA' align='right'>Hello Kitty-Kitty</t>", "Hello-Hello"] ] call dzn_fnc_ShowMessage;
	[ ["<t color='#AAAAAA' align='left'>Hello Kitty</t><br />Hello Again<br /><t color='#AAAAAA' align='right'>Hello Kitty-Kitty</t><br />Hello-Hello"] ] call dzn_fnc_ShowMessage;
	
	
	
	["Hello Kitty", "TOP"] call dzn_fnc_ShowMessage;
	["Hello Kitty", "TOP", [0,0,.2,.8]] call dzn_fnc_ShowMessage;
	["Hello Kitty", "TOP", [0,0,.2,.8], 15] call dzn_fnc_ShowMessage;
	["Hello Kitty", "TOP", [0,0,.2,.8], {A > 0}] call dzn_fnc_ShowMessage;
	
*/

disableSerialization;
#define BG_COLOR					[0,0,0,0.6]
params [
	"_paramText"
	, ["_paramType", "TOP"]
	, ["_paramColor", BG_COLOR]
	, ["_paramTC", "DEFAULT"]
];

if (typename _paramText == "STRING") then { _paramText = [_paramText]; };

private _displayOffsetX = 1;
private _displayOffsetY = 1;
private _displayCharWidth = 74;
if (typename _paramType == "STRING") then {
	_dialogPosition = switch (toUpper(_paramType)) do {		
		case "TOP": {
			_displayOffsetX = 1;
			_displayOffsetY = 1;
			_displayCharWidth = 74;
		};
		case "MIDDLE": {};
		case "BOTTOM": {};
		case "HINT": {};		
	};
} else {
	_displayOffsetX = _paramType select 0;
	_displayOffsetY = _paramType select 1;
	_displayCharWidth = _paramType select 2;
};

private _displayTC = [];
switch (typename _paramTC) do {
	case "CODE": { _displayTC = ["condition", _paramTC]; };
	case "NUMBER": { _displayTC = ["time", _paramTC]; };	
	case "STRING": { _displayTC = ["time", 15]; };
};

missionNamespace setVariable [
	'dzn_Message_Params'
	, [
		_paramText
		, [_displayOffsetX, _displayOffsetY, _displayCharWidth, ceil( ( 38.5 / 74 ) * _displayCharWidth )]		
		, _paramColor
		, _displayTC
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
	private _displayOffsetX = (missionNamespace getVariable 'dzn_Message_Params') select 1 select 0; 
	private _displayOffsetY = (missionNamespace getVariable 'dzn_Message_Params') select 1 select 1; 
	private _displayWidthParam = (missionNamespace getVariable 'dzn_Message_Params') select 1 select 2; 
	private _displayWidth = (missionNamespace getVariable 'dzn_Message_Params') select 1 select 3; 	
	private _displayColor = (missionNamespace getVariable 'dzn_Message_Params') select 2; 
	
	// Define some constants for us to use when laying things out.
	#define GUI_GRID_X		(0)
	#define GUI_GRID_Y		(0)
	#define GUI_GRID_W		(0.025)
	#define GUI_GRID_H		(0.04)
	#define GUI_GRID_WAbs		(1)
	#define GUI_GRID_HAbs		(1)

	#define BASE_IDC			(9600)

	#define BG_X			(_displayOffsetX * GUI_GRID_W + GUI_GRID_X)
	#define BG_Y			(_displayOffsetY * GUI_GRID_H + GUI_GRID_Y)
	#define BG_WIDTH			(_displayWidth * GUI_GRID_W)

	private _dialog = _this select 0;	
	private _background = _dialog ctrlCreate ["IGUIBack", -1];	
	_background ctrlSetPosition [BG_X, BG_Y, BG_WIDTH, 10 * GUI_GRID_H];
	_background ctrlCommit 0;
	
	// Start placing controls 1 units down in the window.
	private _yCoord = BG_Y + (0.5 * GUI_GRID_H);
	private _labelCalculatedTotalRowHeight = 0;
	private _controlCount = 2;

	#define TITLE_WIDTH			((_displayWidth - 2) * GUI_GRID_W)
	#define TITLE_HEIGHT			(1 * GUI_GRID_H)
	#define TITLE_COLUMN_X			(2 * GUI_GRID_W + GUI_GRID_X)

	// Create the label	
	{
		private _isStringText = typename _x == "STRING";
		private _lineBreaks = 0;
		if (_isStringText) then {
			for "_i" from 0 to count(_x) do {
				if ( ["<br />", _x select [_i,6]] call BIS_fnc_inString ) then {
					_lineBreaks = _lineBreaks + 1;
				};		
			};
		};
		
		player sideChat format ["LineBReaks - %1", _lineBreaks];
		
		private _displayTextLength = if (_isStringText) then { count _x } else { count (str _x) };
		private _labelCalculatedRowsHeight = TITLE_HEIGHT * ( ceil ( _displayTextLength / _displayWidthParam ) + _lineBreaks );
		private _labelControl = _dialog ctrlCreate ["RscStructuredText", BASE_IDC + _controlCount];
		_labelControl ctrlSetPosition [TITLE_COLUMN_X, _yCoord, TITLE_WIDTH, _labelCalculatedRowsHeight];
		_labelControl ctrlSetFont "PuristaLight";
		_labelControl ctrlSetStructuredText (if (_isStringText) then { parseText _x } else { _x });
		_labelControl ctrlCommit 0;
		
		_yCoord = _yCoord + _labelCalculatedRowsHeight + (0.4 * GUI_GRID_H);
		_labelCalculatedTotalRowHeight = _labelCalculatedTotalRowHeight + _labelCalculatedRowsHeight + (0.4 * GUI_GRID_H);
		_controlCount = _controlCount + 1;		
	} forEach _displayText;

	// Resize the background to fit
	private _backgroundHeight = (1 * GUI_GRID_H) + _labelCalculatedTotalRowHeight;
	_background ctrlSetPosition [BG_X, BG_Y, BG_WIDTH, _backgroundHeight];
	_background ctrlSetBackgroundColor _displayColor;
	_background ctrlCommit 0;
};



// Show Resource
1000 cutRsc ["dzn_Dynamic_Message","PLAIN"];
switch (_displayTC select 0) do {
	case "time": {
		(_displayTC select 1) spawn { 
			sleep _this; 
			1000 cutFadeOut 2; 
		};
	};
	case "condition": {
		(_displayTC select 1) spawn {
			sleep 5;
			if !(call _this) then {
				1000 cutFadeOut 0;	
				1000 cutRsc ["dzn_Dynamic_Message","PLAIN",0];
			};
		};
	
		(_displayTC select 1) spawn {
			waitUntil { _this };
			1000 cutFadeOut 2;		
		};
	};
};
