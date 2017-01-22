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
	
	call compile preProcessFileLineNumbers "ShowMessage2.sqf";
	
	["Hello Kitty"] call dzn_fnc_sm2;
	
_display ctrlCreate ["RscText", 1234];

with uiNamespace do { 
	dzn_ProgressBar = findDisplay 46 ctrlCreate ["RscText", -1];
	dzn_ProgressBar ctrlSetPosition [0, 0.8, 1, 0.05] ;
	dzn_ProgressBar ctrlSetText "Showed Message";
	dzn_ProgressBar ctrlCommit 0;
};


[] spawn { 
for "_i" from 0 to 10 do {
sleep 1;
with uiNamespace do { 
	dzn_DM2 = findDisplay 46 ctrlCreate ["IGUIBack", -1];
	dzn_DM2 ctrlSetPosition [0, 0.8, 1, 0.05] ;
	dzn_DM2 ctrlSetBackgroundColor [0,0,.2,.8];	
	dzn_DM2 ctrlCommit 0;
	
	dzn_DM = findDisplay 46 ctrlCreate ["RscText", -1];
	dzn_DM ctrlSetPosition [0, 0.8, 1, 0.05] ;
	dzn_DM ctrlSetText format ["Showed Message - %1", _i];	
	dzn_DM ctrlCommit 0;
};

"RscTitleStructuredText"
with uiNamespace do { 
	dzn_DM2 = findDisplay 46 ctrlCreate ["IGUIBack", -1];
	dzn_DM2 ctrlSetPosition [0, 0.8, 1, 0.05] ;
	dzn_DM2 ctrlSetBackgroundColor [0,0,.2,.8];	
	dzn_DM2 ctrlCommit 0;
	
	dzn_DM = findDisplay 46 ctrlCreate ["RscText", -1];
	dzn_DM ctrlSetPosition [0, 0.8, 1, 0.05] ;
	dzn_DM ctrlSetText format ["Showed Message - %1", _i];	
	dzn_DM ctrlCommit 0;
};


};
};


#define TITLETEXT_DISPLAY	(uinamespace getvariable "RscTitleStructuredText")
#define TITLETEXT_CONTROL	(TITLETEXT_DISPLAY displayctrl 9999)

titlersc ["RscTitleStructuredText","plain"];
waituntil {!isnil {TITLETEXT_DISPLAY}};

private ["_text"];
_text = _this param [0,"",[""]];
TITLETEXT_CONTROL ctrlsetstructuredtext parsetext _text;

true



	["Hello Kitty"] call dzn_fnc_sm2;
	[ ["Hello Kitty"] ] call dzn_fnc_ShowMessage;
	[ ["Hello Kitty", "Hello Again", "Hello Kitty-Kitty", "Hello-Hello"] ] call dzn_fnc_ShowMessage;
	[ ["<t color='#AAAAAA' align='left'>Hello Kitty</t>", "Hello Again", "<t color='#AAAAAA' align='right'>Hello Kitty-Kitty</t>", "Hello-Hello"] ] call dzn_fnc_ShowMessage;
	[ ["<t color='#AAAAAA' align='left'>Hello Kitty</t><br />Hello Again<br /><t color='#AAAAAA' align='right'>Hello Kitty-Kitty</t><br />Hello-Hello"] ] call dzn_fnc_ShowMessage;
	
	["Hello Kitty", "TOP"] call dzn_fnc_ShowMessage;
	["Hello Kitty", "TOP", [0,0,.2,.8]] call dzn_fnc_ShowMessage;
	
	["Hello Kitty", "TOP", [0,0,.2,.8], "A > 0"] call dzn_fnc_ShowMessage;
	
	call compile preProcessFileLineNumbers "ShowMessage2.sqf";
	["Hello Kitty<br />Hello Kitty 2<br />Hello Kity 3", "TOP", [0,0,.2,.8], 15] call dzn_fnc_sm2;
		
	["Hello Kitty", "TOP", [0,0,.2,.8], 15] call dzn_fnc_sm2;
	
	["Hello Kitty"] call dzn_fnc_sm2;
*/

dzn_fnc_sm2 = {
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
private _displayWidth = ceil( ( 38.5 / 74 ) * (_labelPos select 2) );

//	Condition or Time

private _displayTC = [];
switch (typename _paramTC) do {	
	case "NUMBER": { _displayTC = ["time", _paramTC]; };	
	case "STRING": { _displayTC = ["condition", _paramTC]; };
	default { _displayTC = ["time", 15]; };
};

// ["Hello Kitty<br />Hello Kitty 2<br />Hello Kity 3", 74] call dzn_fnc_CountTextLines;
private _isStringText = typename _paramText == "STRING";
// private _rowsNumber = [if (_isStringText) then { _paramText } else { str(_paramText) }, 74] call dzn_fnc_CountTextLines;
// _labelPos set [3, (_labelPos select 3) * _rowsNumber];

systemChat format ["Rows: %1 , Label pos: %2", _rowsNumber, str(_labelPos)];

// Display UI
if (isNil {uiNamespace getVariable "dzn_DynamicLabel"}) then { uiNamespace setVariable ["dzn_DynamicLabel", []]; };


with uiNamespace do { 
	if !(dzn_DynamicLabel isEqualTo []) then {
		hint "Dialog exists";
		{ ctrlDelete _x; } forEach dzn_DynamicLabel;
	};
	
	private _label = findDisplay 46 ctrlCreate ["RscStructuredText", -1];
	_label ctrlSetBackgroundColor _paramBackgroundColor;	
	_label ctrlSetPosition _labelPos;

	
	_label ctrlSetStructuredText (if (_isStringText) then { parseText _paramText } else { _paramText });;
	_label ctrlSetFont "PuristaLight";
	systemChat str(ctrlTextHeight _label);
	 // [_label] call BIS_fnc_ctrlTextHeight;
	
	_label ctrlCommit 0;
	[_label, 0.04,0] call BIS_fnc_ctrlFitToTextHeight;
	
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

};

