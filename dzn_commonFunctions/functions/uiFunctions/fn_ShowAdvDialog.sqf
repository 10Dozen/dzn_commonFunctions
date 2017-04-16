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

Added: Multi-line version UI classes RscTextMulti and RscEditMulti for use with scripted controls


[
	[0, "HEADER", "Title text"]
	,[1, "LABEL", "Select player"]
	,[1, "LABEL", "Select player 2"]
] call dzn_fnc_ShowAdvDialog;

[
	[0, "HEADER", "Title text"]
	,[1, "LABEL", "Select player"]
	,[1, "LABEL", "Select player 2"]
	,[2, "BUTTON", "Select", [], [], {hint "SELECTED"}]
	,[3, "BUTTON", "Say hi", [], [], {hint "Hi!"}]
	,[3, "BUTTON", "Say bye", [], [], {hint "Bye-bye!"}]
] call dzn_fnc_ShowAdvDialog;


*/
private _defaultTextStyling = [[1,1,1,1], 0.04, "PuristaLight", "left"] ;
private _defaultElementStyling = [[0,0,0,0.7], 0.04];
private _defaultHeaderStyling = [[0.77, 0.51, 0.08, 0.8] , 0.04];

_fnc_setItem = {
	// [ @item, @Size, @Color, @Text ] call _fnc_setItem

	(_this select 0) ctrlSetBackgroundColor (_this select 2);
	(_this select 0) ctrlSetPosition (_this select 1);
	(_this select 0) ctrlCommit 0;
};

private _itemsProperties = [];
{
	/* Parse parameters */
	private _line = _x select 0;
	private _type = toUpper(_x select 1);
	private _data = _x select 2;
	private _textParams = _defaultTextStyling;
	private _tileParams = if (_type == "HEADER") then { _defaultHeaderStyling } else { _defaultElementStyling };
	private _expression = {true};
	
	private _widthMultiplier = 1 / ( {(_x select 0 )== _line} count _this );
	
	if (!isNil {_x select 3}) then {
		_textParams = if ( (_x select 3) isEqualTo [] ) then { _defaultTextStyling } else { _x select 3 };
		if (!isNil {_x select 4}) then {
			_tileParams  = if ( (_x select 4) isEqualTo [] ) then { _defaultElementStyling } else { _x select 4 };
			if (!isNil {_x select 5}) then {_expression = _x select 5;};
		};
	};
	
	private _lineProperties = [_line, _type, _data, _textParams, _tileParams, ((str(_expression) splitString "") select [1, count str(_expression) - 2]) joinString "", _widthMultiplier];
	
	if (isNil {_itemsProperties select _line}) then {
		_itemsProperties set [_line, [ _lineProperties ]];
	} else {
		(_itemsProperties select _line) pushBack _lineProperties;
	};	
} forEach _this;

XC = _itemsProperties;

with uiNamespace do { 
	createDialog "dzn_Dynamic_Dialog_Advanced";
	private _dialog = findDisplay 134800;
	private _items = [];
	
	private _background = _dialog ctrlCreate ["RscText", -1];
	_background ctrlSetBackgroundColor [0,0,0,.6];
	_background ctrlSetPosition [0, 0.045, 1, 0.045 * ((count _itemsProperties)-1) ];
	_background ctrlCommit 0;
	
	private _crtlId = 14500;
	
	{
		private _lineItems = _x;
		private _yOffset = _forEachIndex * 0.045;
		
		{			
			private _xOffset = _forEachIndex / (count _lineItems);	// For 2 grid: 0 = 0; 1 = 1/2 = 0.5
			
			// [ 0@_line, 1@_type, 2@_data, 3@_textParams, 4@_tileParams, 5@_expression, 6@_widthMultiplier];
			private _line = _x select 0;
			private _type = _x select 1;
			private _data = _x select 2;
			private _textStyle = _x select 3;	// [ 0@Color, 1@Size, 2@Font, 3@Align ]	
			private _tileStyle = _x select 4;	// [ 0@Color, 1@Height ]
			private _expression = _x select 5;
			private _widthMultiplier = _x select 6;		
			
			private _item = -1;
			switch (_type) do {
				case "HEADER": {
					_item = _dialog ctrlCreate ["RscText", -1];
					_item ctrlSetPosition [0, _yOffset, 1, 0.04];
					_item ctrlSetBackgroundColor (_tileStyle select 0);
				};
				case "LABEL": {
					_item = _dialog ctrlCreate ["RscText", -1];
					_item ctrlSetPosition [_xOffset, _yOffset, 1*_widthMultiplier, 0.045];
				};
				case "DROPDOWN": {
					_item = _dialog ctrlCreate ["RscCombo", _crtlId];
					_item ctrlSetPosition [_xOffset, _yOffset, _widthMultiplier, 0.045];		
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
				};
				case "INPUT": {
					_item = _dialog ctrlCreate ["RscEdit", _crtlId];
					_item ctrlSetPosition [_xOffset, _yOffset, _widthMultiplier, 0.045];		
					_item ctrlSetBackgroundColor (_tileStyle select 0);
					_item ctrlSetEventHandler [
						"KeyUp"
						, "missionNamespace setVariable [
							'dzn_DynamicAdvDialog_ReturnValue_" + str (_crtlId) + "'
							, ctrlText (_this select 0)
						];"
					];
					
					_item ctrlSetFont (_textStyle select 2);
					_item ctrlSetTextColor (_textStyle select 0);
				};
				case "BUTTON": {
					_item = _dialog ctrlCreate ["RscButtonMenuOK", _crtlId];					
					_item ctrlSetPosition [
						_xOffset + 0.01*_widthMultiplier
						, _yOffset
						, 0.99*_widthMultiplier
						, 0.04
					];
					_item ctrlSetBackgroundColor (_tileStyle select 0);
					_item ctrlSetEventHandler ["ButtonClick", _expression];
				};
			};
			
			if !(_type in ["DROPDOWN","INPUT"]) then {
				_item ctrlSetText _data;
				_item ctrlSetFont (_textStyle select 2);
				_item ctrlSetTextColor (_textStyle select 0);
			};
			
			_item ctrlCommit 0;
		
			_crtlId = _crtlId + 1;
			_items pushBack _item;
		} forEach _lineItems;	
	} forEach _itemsProperties;
	
	
	
	
} 
