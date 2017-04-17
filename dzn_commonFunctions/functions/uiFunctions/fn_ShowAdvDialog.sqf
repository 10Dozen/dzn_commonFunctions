/*
[
	[0, "HEADER", "Title text"]
	,[1, "LABEL", "Select player"]
	,[1, "DROPDOWN", [1,2,3,4,5,6]]
	,[2, "LABEL", "Actions"]
	,[3, "BUTTON", "Teleport", [], [], {_this setPosASL (getPosASL player)}]
	,[3, "BUTTON", "Heal", [[1,1,1,1],0.22,'PuristaLight','center'], [[1,1,1,1],0.25], { _this call dzn_fnc_healUnit }]
	
] call dzn_fnc_ShowAdvDialog;

	-----------------------------------------
	| Title text                            |
	-----------------------------------------
	| Select player      |_______________V| |
	| Actions								|
	| |_Teleport________| |_Heal__________| |
	|_______________________________________|

[
	[
		0@LineNo(Number)
		, 1@Type(String)
		, 2@Data(String or Array of string)
		, 3@(optional)TextStyling(Array)		[@Color, @Size, @Font, @Align]
		, 4@(optional)ElementStyling(Array)	[@Color, @Height]
		, 5@(for Button)ExecuteCode(Code)	
	]
]
	// HEADER:
	[ 0@LineNo, 1@Type("HEADER"), 2@Title, 3@TextStyling, 4@TileStyling]
	
	// LABEL
	[ 0@LineNo, 1@Type("LABEL"), 2@Title, 3@TextStyling, 4@TileStyling]
	
	// BUTTON
	[ 0@LineNo, 1@Type("BUTTON"), 2@Title, 3@Code, 4@TextStyling, 5@TileStyling, 6@ActiveTileStyling]
	
	// DROPDOWN
	[ 0@LineNo, 1@Type("LABEL"), 2@[0@Title, 1@Code], 3@TextStyling, 4@TileStyling]
	
	// INPUT	
	[ 0@LineNo, 1@Type("INPUT"), 2@TextStyling, 3@TileStyling]



[
	[0, "HEADER", "Dozins Menu"]
	, [1, "LABEL", "Select player"]
	, [1, "DROPDOWN", ["Player1", "Player2", "Player3"], [{hint "1"},{hint "2"},{hint "3"}]]
	, [2, "LABEL","Reason"]
	, [2, "INPUT"]
	, [3, "BUTTON", "Action 1", {hint "Action 1 executed"}]
	, [3, "BUTTON", "Action 2", {hint "Action 2 executed"}]
	, [3, "BUTTON", "Action 3", {hint "Action 3 executed"}]
	, [3, "BUTTON", "Action 4", {hint "Action 4 executed"}]
] call dzn_fnc_ShowAdvDialog


((str(_expression) splitString "") select [1, count str(_expression) - 2]) joinString ""

Added: Multi-line version UI classes RscTextMulti and RscEditMulti for use with scripted controls
*/
#define	IF_NIL(X,Y)	if (isNil {X}) then { Y } else { X }
private _defaultTextStyling 		= [[1,1,1,1], "PuristaLight", 0.04];
private _defaultElementStyling 		= [0,0,0,0.7];
private _defaultHeaderStyling 		= [0.77, 0.51, 0.08, 0.8];
private _defaultActiveElementStyling 	= [1,1,1,0.7];

private _itemsProperties = [];
private _itemsVerticalOffsets = [];
{
	/* Parse parameters */
	private _line = _x select 0;
	private _type = toUpper(_x select 1);
	private _data = "";
	private _textParams = _defaultTextStyling;
	private _tileParams = _defaultElementStyling;
	private _activeTileParams = _defaultActiveElementStyling;
	private _expression = "true";
	
	switch (_type) do {
		case "HEADER": {
			// [ 0@LineNo, 1@Type("HEADER"), 2@Title, 3@TextStyling, 4@TileStyling ]
			_data = _x select 2;
			_tileParams = _defaultHeaderStyling;
			
			if (isNil {_x select 3}) then {
				_textParams = _defaultTextStyling;
			} else {
				_textParams = _x select 3;
				_tileParams = if (isNil {_x select 4}) then { _defaultHeaderStyling } else { _x select 4 };
			};
		};
		case "LABEL": {
			// [ 0@LineNo, 1@Type("LABEL"), 2@Title, 3@TextStyling, 4@TileStyling ]
			_data = _x select 2;
			if !(isNil {_x select 3}) then {
				_textParams = _x select 3;
				if !(isNil {_x select 4}) then { _tileParams = _x select 4 };
			};
		};
		case "BUTTON": {		
			// [ 0@LineNo, 1@Type("BUTTON"), 2@Title, 3@Code, 4@TextStyling, 5@TileStyling, 6@ActiveTileStyling ]
			//,[[2,"BUTTON","Select",[],{hint "SELECTED"},[1,1,1,0.7],"",1]]
			_data = _x select 2;
			if !(isNil {_x select 3}) then {
				_expression = ((str(_x select 3) splitString "") select [1, count str(_x select 3) - 2]) joinString "";
				if !(isNil {_x select 4}) then { 
					_textParams = _x select 4;
					if !(isNil {_x select 5}) then { 
						_tileParams = _x select 5;
						if !(isNil {_x select 6}) then { _activeTileParams = _x select 6 };
					};
				};
			};
		};
		case "DROPDOWN": {
			// [ 0@LineNo, 1@Type("LABEL"),	2@TextItems, 3@ExpressionsPerItem, 4@TextStyling, 5@TileStyling ]
			_data = _x select 2;
			if !(isNil {_x select 3}) then {
				_expression = _x select 3;
				if !(isNil {_x select 4}) then { 
					_textParams = _x select 4;
					if !(isNil {_x select 5}) then { _tileParams = _x select 5; };
				};
			}  else {
				_expression = [{true}];
			};
		};
		case "INPUT": {
			// [ 0@LineNo, 1@Type("INPUT"), 2@TextStyling, 3@TileStyling ]
			if !(isNil {_x select 2}) then {
				_textParams = _x select 2;
				if !(isNil {_x select 3}) then { _tileParams = _x select 3; };
			};
		};	
	};
	
	private _widthMultiplier = 1 / ( {(_x select 0 )== _line} count _this );
	private _lineProperties = [_line, _type, _data, _textParams, _tileParams, _activeTileParams, _expression, _widthMultiplier];
	
	if (isNil {_itemsProperties select _line}) then {
		_itemsProperties set [_line, [ _lineProperties ]];
		_itemsVerticalOffsets set [_line, (_textParams select 2) + 0.005];
	} else {
		(_itemsProperties select _line) pushBack _lineProperties;
		_itemsVerticalOffsets set [_line, (_itemsVerticalOffsets select _line) max ((_textParams select 2) + 0.005) ];
	};	
} forEach _this;

XC = _itemsProperties;
XC2 = _itemsVerticalOffsets;

with uiNamespace do { 
	createDialog "dzn_Dynamic_Dialog_Advanced";
	private _dialog = findDisplay 134800;
	private _items = [];
	
	private _crtlId = 14500;
	private _background = _dialog ctrlCreate ["RscText", -1];
	
	private _yOffset = 0;
	{
		private _lineItems = _x;		
		private _ySize = _itemsVerticalOffsets select _forEachIndex;
		
		{			
			private _xOffset = _forEachIndex / (count _lineItems);	// For 2 grid: 0 = 0; 1 = 1/2 = 0.5
			
			// [ 0_line, 1_type, 2_data, 3_textParams, 4_tileParams, 5_activeTileParams, 6_expression, 7_widthMultiplier]
			private _line = _x select 0;
			private _type = _x select 1;
			private _data = _x select 2;
			private _textStyle = _x select 3;	// [ 0@Color, 1@Font, 2@Size ]	
			private _tileStyle = _x select 4;	// 0@Color
			private _activeStyle = _x select 5; // @Color
			private _expression = _x select 6;
			private _widthMultiplier = _x select 7;		
			
			private _item = -1;

				// [ 0@LineNo, 1@Type("HEADER"), 2@Title, 3@TextStyling, 4@TileStyling]
				// [ 0@LineNo, 1@Type("LABEL"), 2@Title, 3@TextStyling, 4@TileStyling]
				// [ 0@LineNo, 1@Type("BUTTON"), 2@Title, 3@Code, 4@TextStyling, 5@TileStyling, 6@ActiveTileStyling]
				// [ 0@LineNo, 1@Type("LABEL"), 2@[0@Title, 1@Code], 3@TextStyling, 4@TileStyling]
				// [ 0@LineNo, 1@Type("INPUT"), 2@TextStyling, 3@TileStyling]
			switch (_type) do {
				case "HEADER": {				
					_item = _dialog ctrlCreate ["RscStructuredText", -1];
					_item ctrlSetPosition [0, _yOffset, 1, _ySize - 0.005];
					_item ctrlSetBackgroundColor _tileStyle;
				};
				case "LABEL": {
					_item = _dialog ctrlCreate ["RscStructuredText", -1];
					_item ctrlSetPosition [_xOffset, _yOffset, _widthMultiplier, _ySize];
				};
				case "DROPDOWN": {
					_item = _dialog ctrlCreate ["RscCombo", _crtlId];
					_item ctrlSetPosition [_xOffset, _yOffset, _widthMultiplier, _ySize];		
					_data apply { 
						_item lbAdd (if (typename _x == "STRING") then { _x } else { str(_x) });
					};
					_item lbSetCurSel 0;
					_item ctrlSetEventHandler [
						"LBSelChanged"
						, "missionNamespace setVariable [
							'dzn_DynamicAdvDialog_ReturnValue_" + str (_crtlId) + "'
							, [_this select 1, (_this select 0) lbText (_this select 1)]
						];"
					];		
					
					missionNamespace setVariable [
						format["dzn_DynamicAdvDialog_ReturnValue_%1",_crtlId]
						,_expression
					];
				};
				case "INPUT": {
					_item = _dialog ctrlCreate ["RscEdit", _crtlId];
					_item ctrlSetPosition [_xOffset, _yOffset, _widthMultiplier, _ySize];		
					_item ctrlSetBackgroundColor _tileStyle;
					_item ctrlSetEventHandler [
						"KeyUp"
						, "missionNamespace setVariable [
							'dzn_DynamicAdvDialog_ReturnValue_" + str (_crtlId) + "'
							, ctrlText (_this select 0)
						];"
					];
					
				};
				case "BUTTON": {
					_item = _dialog ctrlCreate ["RscButtonMenuOK", _crtlId];					
					_item ctrlSetPosition [
						_xOffset + 0.01*_widthMultiplier
						, _yOffset
						, 0.99*_widthMultiplier
						, _ySize - 0.005
					];
					_item ctrlSetBackgroundColor _tileStyle;
					_item ctrlSetActiveColor _activeStyle;
					_item ctrlSetEventHandler ["ButtonClick", _expression];
				};
			};
			
			if !(_type in ["DROPDOWN","INPUT"]) then {
				_item ctrlSetStructuredText parseText _data;
				// _item ctrlSetText _data;
			};
			_item ctrlSetTextColor (_textStyle select 0);
			_item ctrlSetFont (_textStyle select 1);
			_item ctrlSetFontHeight (_textStyle select 2);
			
			_item ctrlCommit 0;
		
			_crtlId = _crtlId + 1;
			_items pushBack _item;
		} forEach _lineItems;
		
		_yOffset = _yOffset + _ySize;
	} forEach _itemsProperties;
	
	CX3 = _yOffset;
	_background ctrlSetBackgroundColor [0,0,0,.6];
	_background ctrlSetPosition [0, (_itemsVerticalOffsets select 0), 1, _yOffset - (_itemsVerticalOffsets select 0) ];	//0.045 * ((count _itemsProperties)-1) ];
	_background ctrlCommit 0;
} 
