/*
	@Result = [@Distance, @HeightDelta, @Charges] call dzn_fnc_selectFiremissionCharge;
	
	OUTPUT: Array of [@Angle, @Velocity, @TravelTime, @ChargeNo]
*/
params["_d","_h",["_charges", [66,149,208,259,305]]];

private _g = 9.82;
private _result = [];

{
	private _evaluated = _x^4 - _g*(_g*_d^2 + 2*_h*_x^2);
	private _angle = -1;
	private _time = -1;
	if (_evaluated > 0) exitWith {
		_angle = atan( (_x^2 + sqrt(_evaluated))/(_g * _d) );
		_time = (_x * sin(_angle) + sqrt((_x * sin _angle)^2 + 2*_g*_h)) / _g;

		_result = [_angle, _x, _time, _forEachIndex + 1];
	};
} forEach _charges;

_result
