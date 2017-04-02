/*
		[
			@Object
			, [@text, @color, @size, @Font, @Align]
			, @PositionTemplate or @PositionString
			, @VisibilityCondition
			, (optional) @ChangeSizeOnDistnaceExpression
			, 
			, (optional) [@Icon, @Shadow, @Height, @Witdh, @Angle]
		] call dzn_fnc_addDraw3d
	
	*/
	if !(hasInterface) exitWith {};
	private _fnc_stringify = { ((str(_this) splitString "") select { !(_x in ["{","}"]) }) joinString "" };
	
	params ["_obj", "_textParams", ["_postionParam", "top"], ["_visibilityParam", {true}] ,["_sizeOnDistanceParam", "1 / (player distance _this)"], ["_optionalParams", []]];
	
	_text = str(_textParams select 0);
	if (typename (_textParams select 0) != "STRING") then { 
		_text = (_textParams select 0) call _fnc_stringify;
	};
	private _color = [1,1,1,1];
	private _size = 0.2;	
	private _font = "PuristaMedium";
	private _align = "center";
	
	if !(isNil {_textParams select 1}) then {
		_color = (_textParams select 1) call _fnc_stringify;	
		if !(isNil {_textParams select 2}) then {
			_size = _textParams select 2;			
			if !(isNil {_textParams select 3}) then {
				_font = _textParams select 3;				
				if !(isNil {_textParams select 4}) then { _align = _textParams select 4; };
			};
		};
	};
	
	private _pos = "";
	if (typename _postionParam == "STRING") then {
		_pos = switch toLower(_postionParam) do {
			case "top": {
				"[visiblePosition _this select 0, visiblePosition _this select 1, 2.2]"
			};
			case "middle": {
				"[visiblePosition _this select 0, visiblePosition _this select 1, 1.25]"
			};
			case "under": {
				"[visiblePosition _this select 0, visiblePosition _this select 1, -0.25]"
			};			
			case "overhead": {
				"[visiblePosition _this select 0, visiblePosition _this select 1, ((_this modelToWorld (_this selectionPosition 'head')) select 2) + 0.75]"
			};
			default { "[visiblePosition _this select 0, visiblePosition _this select 1, 2.2]" };
		};
	} else {
		_pos = _postionParam call _fnc_stringify;
	};
	
	private _visibility = if (typename _visibilityParam == "STRING") then { compile _visibilityParam } else { _visibilityParam };
	
	private _sizeOnDistance = if (typename _sizeOnDistanceParam == "STRING") then { _sizeOnDistanceParam } else { _sizeOnDistanceParam call _fnc_stringify };
	
	if (isNil "dzn_draw3d_list") then { dzn_draw3d_list = []; };
	
	private _id = (100000 * count str(_obj));
	for "_i" from 4 to 1 step -1 do { _id = _id + round(random 9) * 10^_i; };
	
	dzn_draw3d_list pushBack [
		_id
		, _obj
		, compile format [
			"['', %1, %2, 0, 0, 0, %3, 2, if (_this != player) then { %4 * %6 } else { %4 }, '%5' ]"
			, _color
			, _pos
			, _text
			, _size
			, _font
			, _sizeOnDistance
		]
		, _visibilityParam
	];
	
	if (isNil "dzn_draw3dEH") then { 
		dzn_draw3dEH = addMissionEventHandler ["Draw3D", {	
			{
				if ((_x select 1) call (_x select 3)) then {
					drawIcon3d ((_x select 1) call (_x select 2));
				};
			} forEach dzn_draw3d_list;	
		}];
	};
	
	(_id)
