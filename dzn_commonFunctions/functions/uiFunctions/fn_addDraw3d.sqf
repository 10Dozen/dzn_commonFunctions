	/*
		[
			@Object
			, [@text, @color, @size, @Font, @Align]
			, @PositionTemplate or @PositionString
			
		] call dzn_fnc_addDraw3d
	
		Position templates:
			"overhead"
			"underfeet"
	*/
	if !(hasInterface) exitWith {};
	
	params ["_obj", "_textParams", ["_postionParam", "overhead"], ["_optionalParams", []]];
	
	private _text = if (isNil {_textParams select 0}) then { "Dummy text" } else { _textParams select 0} ;
	private _color = [1,1,1,1];
	private _size = 0.05;	
	private _font = "PuristaMedium";
	private _align = "center";
	
	if !(isNil {_textParams select 1}) then {
		_color = _textParams select 1;		
		if !(isNil {_textParams select 2}) then {
			_size = _textParams select 2;			
			if !(isNil {_textParams select 3}) then {
				_font = _textParams select 3;				
				if !(isNil {_textParams select 4}) then { _align = _textParams select 4; };
			};
		};
	};
	
	private _pos = "[visiblePosition _this select 0, visiblePosition _this select 1, 2]";
	_pos = switch toLower(_postionParam) do {
		case "overhead": {
			"[visiblePosition _this select 0, visiblePosition _this select 1, ((_this modelToWorld (_this selectionPosition 'head')) select 2) + 0.75]"
		};
		case "underfeet": {
			"[visiblePosition _this select 0, visiblePosition _this select 1, -0.25]"
		};
		default { _postionParam; };
	};
	
	if (isNil "dzn_draw3d_list") then { dzn_draw3d_list = []; };
	
	private _id = (100000 * count str(_obj));
	for "_i" from 4 to 1 step -1 do { _id = _id + round(random 9) * 10^_i; };
	
	dzn_draw3d_list pushBack [
		_id
		, _obj
		, compile format [
			"['', %1, %2, 0, 0, 0, '%3', 2, if (_this != player) then { %4 / (player distance _this) } else { %4 }, '%5' ]"
			, _color
			, _pos
			, _text
			, _size
			, _font
		]
	];
	
	if (isNil "dzn_draw3dEH") then { 
		dzn_draw3dEH = addMissionEventHandler ["Draw3D", {	
			{
				drawIcon3d ((_x select 1) call (_x select 2));
			} forEach dzn_draw3d_list;	
		}];
	};
	
	(_id)
