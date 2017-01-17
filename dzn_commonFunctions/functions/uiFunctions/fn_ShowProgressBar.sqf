/*
	[
		@StartStep (Number)
		, @EndStep (Number)	
		, @InterstepsDelay (Number, seconds) (optional)
		, @PositionTemplate or [@X, @Y, @Width, @Height] (optional)
		, @ExecuteOnFinish (Code) (optional)
		, @Arguments (any) (optional)
	] spawn dzn_fnc_ShowProgressBar
	
	Display customizable Progress bar.
	Code can be executed on finish, _this is referense for arguments array
	
	
	[1, 10, 1, "BOTTOM", { hint format ["Progress done in %1", _this] }, 10] spawn dzn_fnc_ShowProgressBar
*/

params[
	"_startStep"
	, "_endStep"
	, ["_delay", 1]
	, ["_position", "bottom"]
	, ["_code", {}]
	, ["_args", []]
];

private _stepSign = if (_startStep < _endStep) then { 1 } else { -1 };
private _step = _stepSign / (abs (_endStep - _startStep));

private _progress = _startStep;
private _progressEnd = _endStep


with uiNamespace do { 
	dzn_ProgressBar = findDisplay 46 ctrlCreate ["RscProgress", -1];
	dzn_ProgressBar ctrlSetPosition [0,.8,1,0.05];
	dzn_ProgressBar progressSetPosition _startStep;  
	dzn_ProgressBar ctrlCommit 0;
};





for "_i" from 0 to CCP_bar_max do {
	(uiNamespace getVariable "CCP_bar") progressSetPosition CCP_bar_progress;
	(uiNamespace getVariable "CCP_bar") ctrlCommit 0;
	sleep 1;
	CCP_bar_progress = CCP_bar_progress + CCP_bar_step;	
};
	
	ctrlDelete (uiNamespace getVariable "CCP_bar");
