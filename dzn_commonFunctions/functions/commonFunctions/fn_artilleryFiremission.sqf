/*
	[
		@Artillery Unit or @Array of Units
		, [@TgtPos, @Radius] or @Trigger or @Array of Triggers
		, [@Salvos, @Delay, @RoundType] or @Template
	] spawn dzn_fnc_artilleryFiremission;

	// 1 gun, 5 salvos of 1 roound in 5 minutes
	[ Art1, [ [1000,1000,0], 30 ], [5, 1, "Sh_155mm_AMOS"]] spawn dzn_fnc_artilleryFiremission;
	[ Art1, [ [1000,1000,0], 30 ], "Mortar Light"] spawn dzn_fnc_artilleryFiremission;
	[ Art1, [ [1000,1000,0], 30 ], "Mortar Heavy"] spawn dzn_fnc_artilleryFiremission;


	// 3 guns, 10/3=3 salvos of 3 rounds in 1/2*3=1.5 min
	[ [Art1,Art2,Art3], [Trg1, Trg2], [3, 1.5, "Sh_155mm_AMOS"]] spawn dzn_fnc_artilleryFiremission;

	// 2 guns, 6 salvos of 2 rounds in 10 mins
	[ [Art1,Art2], [Trg1], [6, 1.6, "Sh_155mm_AMOS"]]  spawn dzn_fnc_artilleryFiremission;

	// 5 guns, 12 salvos each 5 mins
	[ [Art1, Art2, Art3, Art4, Art5], Trg1, [12, 5, "Sh_155mm_AMOS"]] spawn dzn_fnc_artilleryFiremission;

*/

params["_providerParams","_targetParams","_firemissionParams"];

// Settings //
private _battery = if (typename _providerParams == "ARRAY") then { _providerParams } else { [_providerParams] };

private _tgtAreas = [];
if (typename _targetParams == "ARRAY") then {
	if (typename (_targetParams select 0) == "ARRAY") then {
		private _trg = createTrigger ["EmptyDetector", _target select 0];
        _trg setTriggerArea [_target select 1, _target select 1, 0, false, 0];

        _tgtAreas = [_trg];
	} else {
		_tgtAreas = _targetParams;
	};
} else {
	_tgtAreas = [_targetParams]
};

if (typename _firemissionParams != "ARRAY") then {
	// Template section here
};



// Sequence //

dzn_fnc_art_calculateFiremissionParameters = {
	params["_d","_h","_charges"];
	private _g = 9.82;
	private _result = [];

	{
		private _evaluated = _x^4 - _g*(_g*_d^2 + 2*_h*_x^2);
		private _angle = -1;
		private _time = -1;
		if (_evaluated > 0) then {
			_angle = atan( (_x^2 + sqrt(_x^4 - _g*(_g*_d^2 + 2*_h*_x^2)))/(_g * _d) );
			_time = (_x * sin(_angle) + sqrt((_x * sin _angle)^2 + 2*_g*_h) / _g;
		};

		_result pushBack [_angle, _time];
	} forEach _charges;

	_result
};

// For each Salvo
// 	For each Provider
// 		Add EH
// 		Spawn - doWatch, doTarget, sleep, fireAtTarget
// sleep Delay
{
	_x setVariable ["dzn_artillery_eh",
		_x addEventHandler [
			"Fired"
			, {


			}
		]
	];


} forEach _battery;

for "_i" from 1 to _salvos do {
	{
		private _gun = _x;
		private _tgtPos = (selectRandom _tgtAreas) call dzn_fnc_getRandomPointInZone;
		private _round = _firemissionParams select 2;

		private _firemission = (([)] call dzn_fnc_art_calculateFiremissionParameters) select { _x select 0 > -1 }) select 0;
        _x setVariable ["dzn_artillery_firemission", _firemission]

		_gun setVariable [
			"dzn_artillery_firetable"
			, (_gun getVariable "dzn_artillery_firetable") pushBack [_tgtPos, objNull]
		];

		[_gun, _tgtPos, _round] spawn {
			private _tgt = createVehicle ["TargetP_Inf_F",_this select 1,[],0,"FLY"];
			_tgt setPosASL (_this select 1);

			(_this select 0) doWatch _tgt;
			(_this select 0) doTarget _tgt;

			sleep 5;
			(_this select 0) fireAtTarget [_tgt];
		};
	} forEach _battery;
}
