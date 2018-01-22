/*
 * [@PositionSetting, @ShellClass, @Salvos, @RoundsPerSalvo, @TimeoutPerSalvo, @TimeoutPerRound, @StartCondition, @StopCondition] spawn dzn_fnc_StartVirtualFiremission
 * Plans and provide artillery firemission in given area by spawning shells (no artillery units needed).
 * 
 * INPUT:
 * 0: TRIGGER or ARRAY - Description of the target area. Can be TRIGGER or Array of TRIGGERS or ARRAY in format [@Pos3D, @Shape (can be "CIRCLE" or "LINE"), @Direction fron Pos3d, @Size]. 
 *                Description of the target area. Can be TRIGGER or Array of TRIGGERS or ARRAY in format [@Pos3D, @Shape (can be "CIRCLE" or "LINE"), @Direction fron Pos3d, @Size]. 
 * 1: STRING - Classname of the shells. E.g. "Sh_82mm_AMOS" ,"Smoke_82mm_AMOS_White","Flare_82mm_AMOS_White"
 * 2: NUMBER - Number of salvos to shoot. If negative (e.g. -5) - firemission will be looped until @StopCondition met.
 * 3: NUMBER - (optional) Number of shots in each salvo. Total number of the rounds that will be spawned is Number of salovs * Number of shots in salvo (e.g. for 5 salvos 3 shots each - total is 15 rounds). Default: 3.
 * 4: NUMBER - (optional) Timeout after each salvo. Default: 40.
 * 5: NUMBER - (optional) Timeout after each shot in salvo. It will be slightly randomized (+- 2 seconds). Default: 0.
 * 6: CODE - (optional) Condition to start the firemission. Firemission will be delayed until condition return TRUE. Default: { true }.
 * 7: CODE - (optional) Condition to cancel the firemission in progress. Default: { false }.
 * OUTPUT: NONE
 * 
 * EXAMPLES:
 *      [Trg1, "Sh_82mm_AMOS", 5] spawn dzn_fnc_StartVirtualFiremission;
 *      [[Trg1,Trg2,Trg3], "Sh_82mm_AMOS", -1, 6, 30, 0, { true }, { alive player }] spawn dzn_fnc_StartVirtualFiremission;
 *      [[getMarkerPos "Arty1", "LINE", 90, 500], "Smoke_82mm_AMOS_White", 3] spawn dzn_fnc_StartVirtualFiremission;
 */

params [ 
	"_posSettings" 
	, "_shellType" 
	, "_salvos" 
	, ["_roundsPerSalvo", 3] 
	, ["_timeoutPerSalvo", 40] 
	, ["_timeoutPerRound", 0] 
	, ["_startCondition", { true }] 
	, ["_stopCondition", { false }] 
];


private _tgts = [];
private _totalRounds = abs(_salvos) * _roundsPerSalvo;

if (typename _posSettings == "ARRAY") then {
	switch (typename (_posSettings select 0)) do {
		case "OBJECT": {
			// List of triggers
			for "_i" from 1 to _totalRounds do { _tgts pushBack (_posSettings call dzn_fnc_getRandomPointInZone); };
		};
		case "ARRAY": {
			// Pos3d
			private _basepoint = _posSettings select 0;
			private _shape = _posSettings select 1;
			private _dir = _posSettings select 2;
			private _dist = _posSettings select 3;			
			private _step = _dist / _totalRounds;
			
			if (toUpper(_shape) == toUpper("CIRCLE")) then {
				for "_i" from 0 to (_totalRounds - 1) do {
					_tgts pushBack (_basepoint getPos [_step * _i * random [0.8, 1, 1.2], random (360)]);		
				};		
			} else {
				for "_i" from 0 to (_totalRounds - 1) do {
					private _pos = _basepoint getPos [_step * _i, _dir];
					_tgts pushBack (_pos getPos [random (_step max 20), random 360]);		
				};
			};
		};
	};
} else {
	if (typename _posSettings == "OBJECT") then {
		// Single Trigger
		for "_i" from 1 to _totalRounds do { _tgts pushBack ([_posSettings] call dzn_fnc_getRandomPointInZone); };
	};
};

waitUntil _startCondition;

for "_i" from 0 to (_totalRounds - 1) step _roundsPerSalvo do {
	if (call _stopCondition) exitWith {};
	
	for "_j" from 0 to (_roundsPerSalvo - 1) do {
		[_tgts select (_i + _j), _shellType, 25, true] call dzn_fnc_spawnShell;
		
		sleep (_timeoutPerRound + random(3));
	};
	
	sleep _timeoutPerSalvo
};

if (_salvos < 0) then { _this spawn dzn_fnc_StartVirtualFiremission; };
