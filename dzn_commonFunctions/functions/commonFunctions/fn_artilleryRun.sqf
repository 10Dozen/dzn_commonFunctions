/*
    	[
		[@Pos3d, @Raius]	or	@Array of Triggers
		, @ProviderObjects or @VirtualBatteryClass
		, [ @RateOfFire, @RoundsPerSalvo, @RoundsType, @MaxRounds ]	
		, @CorrectorsObjects
		, @Condition
	] call dzn_fnc_artilleryRun;
	

	// Arty fire corrected by correctors (3 5-shot salvos per minute, 30 rounds total)
	[ [Trg1, Trg2, Trg3], [Art1,Art2], [3, 5, "Sh_155mm_AMOS", 30], [FO_1, FO_2], { alive FO_1 && alive FO_2 }] call dzn_fnc_artilleryRun;
	
	// Arty fire - random in area (3 1-shot per minute, infinite)
	[ [Trg1, Trg2, Trg3], "Virtual", [3, 1, "Sh_155mm_AMOS"], [], { time < 1500 }] call dzn_fnc_artilleryRun;
	
	
	
*/
params["_posParam", "_providerParam", "_fireParam", "_correctors", "_condition"];

// Position
private _area = if (typename (_posParam select 0) == "ARRAY") then {
	[ createLocation [ "NameVillage" , _posParam select 0, _posParam select 1, _posParam select 1] ];
} else {
	_posParam
};

// Provider
private _providers = if (typename _providerParam == "STRING") then {
	[]	// Virtual	
} else {
	_providerParam
};

// Firemission		, [ @RateOfFire, @RoundsPerSalvo, @RoundsType, @MaxRounds ]	
private _fm_ROF = _fireParam select 0;
private _fm_Salvo = _fireParam select 1;
private _fm_Type = _fireParam select 2;
private _fm_Max = _fireParam select 3;

// Correctors
private _isCorrected = if (_correctorsParam isEqualTo []) then { false } else { true };


// End of Settings


