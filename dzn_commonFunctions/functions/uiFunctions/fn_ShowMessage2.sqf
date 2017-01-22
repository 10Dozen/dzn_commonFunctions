/*
	[ 
		@Text(lines in array, can be raw (not parsed) StructuredText)
		, @Position_Template or [@X, @Y, @DialogWidth(Chars), @LineHeight]
		, @BG_Color
		, @Duration or @ConditionToHide
	] call dzn_fnc_ShowMessage
	
	Display customizable Hint message.
	nil call dzn_fnc_ShowMessage - initialization
	
	["Hello Kitty"] call dzn_fnc_ShowMessage;
	[ ["Hello Kitty"] ] call dzn_fnc_ShowMessage;
	[ ["Hello Kitty", "Hello Again", "Hello Kitty-Kitty", "Hello-Hello"] ] call dzn_fnc_ShowMessage;
	[ ["<t color='#AAAAAA' align='left'>Hello Kitty</t>", "Hello Again", "<t color='#AAAAAA' align='right'>Hello Kitty-Kitty</t>", "Hello-Hello"] ] call dzn_fnc_ShowMessage;
	[ ["<t color='#AAAAAA' align='left'>Hello Kitty</t><br />Hello Again<br /><t color='#AAAAAA' align='right'>Hello Kitty-Kitty</t><br />Hello-Hello"] ] call dzn_fnc_ShowMessage;
	
	["Hello Kitty", "TOP"] call dzn_fnc_ShowMessage;
	["Hello Kitty", "TOP", [0,0,.2,.8]] call dzn_fnc_ShowMessage;
	["Hello Kitty", "TOP", [0,0,.2,.8], 15] call dzn_fnc_ShowMessage;
	["Hello Kitty", "TOP", [0,0,.2,.8], "A > 0"] call dzn_fnc_ShowMessage;
	
	
	["Hello Kitty", [1,1,74]] call dzn_fnc_ShowMessage;
	
	
	with uiNamespace do { 
		dzn_ProgressBar = findDisplay 46 ctrlCreate ["RscText", -1];
		dzn_ProgressBar ctrlSetPosition [0, 0.8, 1, 0.05] ;
		dzn_ProgressBar ctrlSetText "Showed Message";
		dzn_ProgressBar ctrlCommit 0;
	};
*/
disableSerialization;

params [
	"_paramText"
	, ["_paramPos", "TOP"]
	, ["_paramBackgroundColor", [0,0,0,.6]]
	, ["_paramTC", 15]
];

// Parameters
// 	Position
private _labelPos = [];
if (typename _paramPos == "STRING") then {
	_labelPos = switch (toUpper(_paramPos)) do {		
		case "BOTTOM": { 	[0, 0.8, 1, 0.04] };
		case "TOP": { 	[0, 0.3, 1, 0.04] };
	};
} else {
	_labelPos = _paramPos;
};
//	Condition or Time
private _displayWidth = ceil( ( 38.5 / 74 ) * (_labelPos select 2) );
private _displayTC = [];
switch (typename _paramTC) do {	
	case "NUMBER": { _displayTC = ["time", _paramTC]; };	
	case "STRING": { _displayTC = ["condition", _paramTC]; };
	default { _displayTC = ["time", 15]; };
};


// Display UI
if (isNil {uiNamespace getVariable "dzn_DynamicLabel"}) then { uiNamespace setVariable ["dzn_DynamicLabel", []]; };

with uiNamespace do { 
	if !(dzn_DynamicLabel isEqualTo []) then {
		hint "Dialog exists";
		{ ctrlDelete _x; } forEach dzn_DynamicLabel;
	};	
	private _isStringText = typename _paramText == "STRING";
	
	private _label = findDisplay 46 ctrlCreate ["RscStructuredText", -1];
	_label ctrlSetBackgroundColor _paramBackgroundColor;	
	_label ctrlSetPosition _labelPos ;
	
	_label ctrlSetStructuredText (if (_isStringText) then { parseText _paramText } else { _paramText });;
	_label ctrlSetFont "PuristaLight";
	_label ctrlCommit 0;
	
	dzn_DynamicLabel = [_label];
};

switch (_displayTC select 0) do {
	case "time": {
		uiNamespace setVariable ["dzn_DynamicLabel_Timer", time + (_displayTC select 1)];
		[] spawn { 
			disableSerialization;
			waitUntil { time > uiNamespace getVariable "dzn_DynamicLabel_Timer" };
			if (uiNamespace getVariable "dzn_DynamicLabel_Timer" == 0) exitWith {};
			
			with uiNamespace do { { ctrlDelete _x; } forEach dzn_DynamicLabel; };
			uiNamespace setVariable ["dzn_DynamicLabel_Timer", 0];
			uiNamespace setVariable ["dzn_DynamicLabel_Condition", "true"];			
		};
	};
	case "condition": {	
		uiNamespace setVariable ["dzn_DynamicLabel_Condition", _displayTC select 1];
		[] spawn {
			disableSerialization;
			waitUntil { call compile (uiNamespace getVariable "dzn_DynamicLabel_Condition") };
			if (uiNamespace getVariable "dzn_DynamicLabel_Condition" == "true") exitWith {};
			

			with uiNamespace do { { ctrlDelete _x; } forEach dzn_DynamicLabel; };
			uiNamespace setVariable ["dzn_DynamicLabel_Timer", 0];
			uiNamespace setVariable ["dzn_DynamicLabel_Condition", "true"];
		};
	};
};
