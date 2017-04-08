// Removes draw3d handler by ID or Obejct; Removes all added draw3d if no argument passed

if (isNil "dzn_draw3d_list") exitWith {};

if (typename _this == "ARRAY" && { _this isEqualTo [] }) exitWith { dzn_draw3d_list = []; };

private _checkValue = if (typename _this == "SCALAR") then { 0 } else { 1 };
dzn_draw3d_list = dzn_draw3d_list select { !(_x select _checkValue == _this) };
	
(true)
