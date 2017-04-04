params["_d","_h",["_charges", [66,122,177]]];

private _g = 9.82;
private _result = [];

{
	private _evaluated = _x^4 - _g*(_g*_d^2 + 2*_h*_x^2);
	private _angle = -1;
	private _time = -1;
	if (_evaluated > 0) exitWith {
		_angle = atan( (_x^2 + sqrt(_x^4 - _g*(_g*_d^2 + 2*_h*_x^2)))/(_g * _d) );
		_time = (_x * sin(_angle) + sqrt((_x * sin _angle)^2 + 2*_g*_h) / _g;

		// @VelocityVector, @Angle, @Time
		_result = [[0,_x * sin _angle, _x * cos _angle], _angle, _time];
	};
} forEach _charges;

_result
