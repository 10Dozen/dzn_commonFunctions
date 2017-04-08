
private _battery = if (typename _this == "ARRAY") then { _this } else { [_this] };

{
	_x setVariable ["dzn_artillery_inFiremission", false, true];
} forEach _battery;