/*
    	[
		[@Pos3d, @Raius]	or	@Array of Triggers
		, @ProviderObjects or @VirtualBatteryClass
		, [ @RateOfFire, @RoundsPerSalvo, @RoundsType, @MaxRounds ]	
		, @CorrectorsObjects
		, @Condition
	] call dzn_fnc_artilleryRun;
	

	[ [Trg1, Trg2, Trg3], [Art1,Art2], [3, 5, "Sh_155mm_AMOS", 30], [FO_1, FO_2], { alive FO_1 && alive FO_2 }] call dzn_fnc_artilleryRun;
	
	[ [Trg1, Trg2, Trg3], "Virtual", [3, 1, "Sh_155mm_AMOS"], [], { time < 1500 }] call dzn_fnc_artilleryRun;
	
*/
