/*
[
	[0, "HEADER", "Title text"]
	,[1, "LABEL", "Select player"]
	,[1, "DROPDOWN", [1,2,3,4,5,6]]
	,[2, "LABEL", "Actions"]
	,[3, "BUTTON", "Teleport", [], [], {_this setPosASL (getPosASL player)}]
	,[3, "BUTTON", "Heal", [[1,1,1,1],0.22,'PuristaLight','center'], [[1,1,1,1],0.25,], { _this call dzn_fnc_healUnit }]
	
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
		@LineNo(Number)
		, @Type(String)
		, @Data(String or Array of string)
		, @(optional)TextSyling(Array)		[@Color, @Size, @Font, @Align]
		, @(optional)ElementStyling(Array)	[@Color, @Height]
		, @(for Button)ExecuteCode(Code)	
	]
]

Added: Multi-line version UI classes RscTextMulti and RscEditMulti for use with scripted controls

*/
with uiNamespace do { 
	private _dialog = findDisplay 46;
	private _background = _dialog ctrlCreate ["RscTextMulti", -1];
	_background ctrlSetBackgroundColor [0,0,0,.6];
	_background ctrlSetPosition [0, 0.3, 1, 0.04];

	{
		/* Parse parameters */
		private _line = _x select 0;
		private _type = _x select 1;
		private _data = _x select 2;
		private _textParams = [];
		private _tileParams = [];
		private _expression = {true};

		if (!isNil {_x select 3}) then {
			_textParams = _x select 3;
			if (!isNil {_x select 4}) then {
				_tileParams = _x select 4;
				if (!isNil {_x select 5}) then {_expression = _x select 5;};
			};
		};
		
		/* Create compoment */
		
		

	} forEach _this;
};
