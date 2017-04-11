#define	DEBUG 		true
/*
	[
		@Artillery Unit or @Array of Units
		, [@TgtPos, @Radius] or @Trigger or @Array of Triggers
		, [@Salvos, @Delay, @(optional)RoundType]
		, @(optional)BarrageFire (true by default)
		, @(optional)ConditionToRun (code with _this reference to gun)
	] spawn dzn_fnc_artilleryFiremission;

	
	
	// 1 gun, 5 salvos of 1 roound in 5 minutes
	[ Art1, [ [1000,1000,0], 30 ], [5, 10, "Sh_155mm_AMOS"]] spawn dzn_fnc_artilleryFiremission;
	[ Art1, [Trg1,Trg2], [5, 20]] spawn dzn_fnc_artilleryFiremission;
	[ Art4, Trg2, [5, 2]] spawn dzn_fnc_artilleryFiremission;
	[ Art4, Trg2, [5,2,"8Rnd_82mm_Mo_Smoke_white"]] spawn dzn_fnc_artilleryFiremission;
	[[Art3,Art4], [Trg1,Trg2], [ -30,2 ]] spawn dzn_fnc_artilleryFiremission
	
	// 3 guns, 3 salvos of total 9 rounds in 20*3 = 60 seconds
	[ [Art1,Art2,Art3], [Trg1, Trg2], [3, 20, "8Rnd_82mm_Mo_Smoke_white"]] spawn dzn_fnc_artilleryFiremission;

	// 2 guns, 6 salvos of 2 rounds in 10 mins
	[ [Art1,Art2], [Trg1], [6, 1.6, "8Rnd_82mm_Mo_Smoke_white"]]  spawn dzn_fnc_artilleryFiremission;

	// 5 guns, 12 salvos each of total 60 rounds in 12*35 = 7 mins, searching fire
	[ [Art1, Art2, Art3, Art4, Art5], Trg1, [12, 35], false] spawn dzn_fnc_artilleryFiremission;
*/

params[
	"_providerParams"
	,"_targetParams"
	,"_firemissionParams"
	,["_isBarrageFire",true]
	,["_condition",{true}]
];

// Settings //
private _battery = if (typename _providerParams == "ARRAY") then { _providerParams } else { [_providerParams] };
if ( _battery select { !(_x getVariable ["dzn_artillery_inFiremission",false]) } isEqualTo [] ) exitWith { 
	diag_log "dzn_artillery: Guns are busy";
	false
};

private _tgtAreas = [];
private _tgtGeneratedArea = objNull;

if (typename _targetParams == "ARRAY") then {
	if (typename (_targetParams select 0) == "ARRAY") then {
		_tgtGeneratedArea = createTrigger ["EmptyDetector", _targetParams select 0];
		_tgtGeneratedArea setTriggerArea [_targetParams select 1, _targetParams select 1, 0, false, 0];
		_tgtAreas = [_tgtGeneratedArea];
	} else {
		_tgtAreas = _targetParams;
	};
} else {
	_tgtAreas = [_targetParams];
};

private _salvos = _firemissionParams select 0;
private _delay = if ((_firemissionParams select 1) <= 8) then { 8 } else { _firemissionParams select 1 };
private _round = if (isNil {_firemissionParams select 2}) then { "" } else { _firemissionParams select 2 };;
private _useVirtualMagazine = false;

if (_salvos < 0) then { 
	_salvos = abs(_salvos);
	_useVirtualMagazine = true;
};

/*
 *	Sequence 
 */
{
	if (DEBUG) then {
		if !(_x getVariable ["dzn_artillery_tracer", false]) then {
			[_x] spawn BIS_fnc_traceBullets;
			_x setVariable ["dzn_artillery_tracer",true,true];
		};
	};
	
	_x setVariable ["dzn_artillery_inFiremission", true, true];
	if (_x getVariable ["dzn_artillery_defaultRound",""] == "") then {
		_x setVariable ["dzn_artillery_defaultRound", magazines _x select 0,true];
	};	
	
	if (_round != (weaponState [_x, [0]]) select 3) then {
		if (_round != "") then {
			_x loadMagazine [[0], (weapons _x) select 0, _round];
		} else {
			_x loadMagazine [[0], (weapons _x) select 0, _x getVariable "dzn_artillery_defaultRound"];
		};
	};
	
	_x setVariable ["dzn_artillery_useVirtualMagazine", _useVirtualMagazine,true];	
	_x setVariable ["dzn_artillery_eh",
		_x addEventHandler [
			"Fired"
			, {				
				[_this select 6,  (_this select 0) getVariable "dzn_artillery_firemission"] spawn {
					[_this select 0, ["V"], "center", {true}, {1}] call dzn_fnc_AddDraw3d;
				
					params["_shell", "_firemission"];
					
					waitUntil { (getPosATL _shell select 2) > 150 };
					systemChat "Shell altitude: >150m";
					
					waitUntil { (getPosATL _shell select 2) < 200 };
					systemChat "Shell altitude: <200m - Correction";
					
					// [0@Angle, 1@Velocity, 2@TravelTime, 3@ChargeNo, 4@Direction, 5@TGTPosition]					
					[
						_shell
						, _firemission select 4
						, -( acos ( (_shell distance2d (_firemission select 5)) / (_shell distance (_firemission select 5)) ) )
						, 50
					] call dzn_fnc_setVelocityDirAndUp;				
				};
				
				/*
				private _fmParams = (_this select 0) getVariable "dzn_artillery_firemission"; // [0@Angle, 1@Velocity, 2@TravelTime, 3@ChargeNo, 4@Direction];
				private _shell = _this select 6;				
				
				[_shell, _fmParams select 4, _fmParams select 0, _fmParams select 1] call dzn_fnc_setVelocityDirAndUp;
				*/
				
				if ((_this select 0) getVariable "dzn_artillery_useVirtualMagazine") then { (_this select 0) setVehicleAmmo 1; };
				(_this select 0) setVariable ["dzn_artillery_shotsInProgress", false, true];
			}
		]
		,true
	];
} forEach _battery;


for "_i" from 1 to _salvos do {	
	{
		if (_isBarrageFire) then {
			sleep _delay;
		} else {
			sleep (if ( (_delay/(count _battery)) < 8 ) then { 8 } else { ( _delay/(count _battery) ) });
		};
		
		if (
			(
				alive (gunner _x) 
				|| !((gunner _x) getVariable ["ACE_isUnconscious", false])				
			) 
			&& _x call _condition
			&& _x getVariable "dzn_artillery_inFiremission"			
		) then { 		
			if ((weaponState [_x, [0]]) select 4 == 0) then { reload _x; sleep 3; };
			
			// Calculating shot parameters:	1) Target pos, 2) Direction to target, 3) Angle, 4) Projectile velocity
			private _tgtPos = [selectRandom _tgtAreas] call dzn_fnc_getRandomPointInZone;
			private _firemissionCalculated = [_tgtPos distance2d _x, ((getPosASL _x) select 2) - ((ASLToATL _tgtPos) select 2)] call dzn_fnc_selectFiremissionCharge;
			
			if (_firemissionCalculated isEqualTo []) then { 
				diag_log format["dzn_artillery: %1 - Failed to find appropriate charge for distance %1", _x, _tgtPos distance2d _x];
				systemChat format["dzn_artillery: %1 - Failed to find appropriate charge for distance %1", _x, _tgtPos distance2d _x];
			} else {
				_firemissionCalculated pushBack _tgtPos;
				_firemissionCalculated pushBack (_x getDir _tgtPos);
				
				// [@Angle, @Velocity, @TravelTime, @ChargeNo, @Direction, @TGTPosition]
				_x setVariable ["dzn_artillery_firemission", _firemissionCalculated, true]; 
				_x setVariable ["dzn_artillery_shotsInProgress", true, true];
				[_x, _tgtPos] spawn {
					// private _tgt = createVehicle ["Land_HelipadEmpty_F",_this select 1,[],0,"FLY"];
					private _tgt = createVehicle ["VR_3DSelector_01_default_F",_this select 1,[],0,"NONE"];
					// _tgt setPosASL (_this select 1);

					(_this select 0) doWatch _tgt;
					(_this select 0) doTarget _tgt;

					sleep 5;
					if ( !alive (gunner (_this select 0)) || (gunner (_this select 0)) getVariable ["ACE_isUnconscious", false] ) exitWith { deleteVehicle _tgt;; };
					(_this select 0) fireAtTarget [_tgt];
					
					sleep 1;
					// deleteVehicle _tgt;
				};
			};
		};
	} forEach _battery;
	
	_battery = _battery select { _x getVariable "dzn_artillery_inFiremission" };
};

// End of sequence

waitUntil { (_battery select { _x getVariable ["dzn_artillery_shotsInProgress",false] }) isEqualTo [] };

{
	_x removeEventHandler ["Fired", _x getVariable "dzn_artillery_eh"];
	_x setVariable ["dzn_artillery_inFiremission", false, true];
} forEach _battery;
deleteVehicle _tgtGeneratedArea;

true
