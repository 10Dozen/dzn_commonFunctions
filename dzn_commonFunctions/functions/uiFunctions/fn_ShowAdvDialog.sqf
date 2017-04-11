[
	[0, "HEADER", "Title text"]
	,[1, "LABEL", "Select player"]
	,[1, "DROPDOWN", [1,2,3,4,5,6]]
	,[2, "LABEL", "Actions"]
	,[3, "BUTTON", "Teleport", [], [], {_this setPosASL (getPosASL player)}]
	,[3, "BUTTON", "Heal", [[1,1,1,1],0.22,'PuristaLight','center'], [[1,1,1,1],0.25,], , { _this call dzn_fnc_healUnit }]
	
] call dzn_fnc_ShowAdvDialog;


/*
	-----------------------------------------
	| Title text                            |
	-----------------------------------------
	| Select player      |_______________V| |
	| Actions								|
	| |_Teleport________| |_Heal__________| |
	|_______________________________________|
*/



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

