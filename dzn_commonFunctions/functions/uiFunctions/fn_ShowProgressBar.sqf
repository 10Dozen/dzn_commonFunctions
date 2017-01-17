/*
	[
		@Steps (Number)
		, @InterstepsDelay (Number, seconds) (optional)
		, @PositionTemplate or [@X, @Y, @Width, @Height] (optional)
		, @ExecuteOnFinish (Code) (optional)
		, @Arguments (any) (optional)
	] spawn dzn_fnc_ShowProgressBar
	
	Display customizable Progress bar.
	Code can be executed on finish, _this is referense for arguments array
	
	[10, 1, "BOTTOM", { hint format ["Progress done in %1", _this] }, 10] spawn dzn_fnc_ShowProgressBar
*/
