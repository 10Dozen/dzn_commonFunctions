
if (isNil "dzn_draw3d_list") exitWith {};

private _checkValue = if (typename _this == "SCALAR") then { 0 } else { 1 };
dzn_draw3d_list = dzn_draw3d_list select { !(_x select _checkValue == _this) };
	
(true)
