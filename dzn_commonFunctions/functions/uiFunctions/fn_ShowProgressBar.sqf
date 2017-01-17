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
	0 is treated as initial step (so StartStep 1 means that at least 1 step was done already).
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

/*
	start: 	5
	end:	10
	0...1
	
	1) Get max vlaue: 	max(5,10) = 10
	2) Get step size: 	1/10 = 0.1
	3) How many steps: 	10-5 = 5
	4) Set start step:	5 * 0.1 = 0.5
	5) Start loop from:	5
			to:	10
		      step:	1		      
	     add each step:	0.1
*/
private _scaleMax = max(_startStep, _endStep);
private _stepSign = if (_startStep < _endStep) then { 1 } else { -1 };
private _stepSize = _stepSign * round(1 / _scaleMax);
private _progress = _startStep;

with uiNamespace do { 
	dzn_ProgressBar = findDisplay 46 ctrlCreate ["RscProgress", -1];
	dzn_ProgressBar ctrlSetPosition [0,.8,1,0.05];
	dzn_ProgressBar progressSetPosition _startStep;  
	dzn_ProgressBar ctrlCommit 0;
};

for "_i" from _startStep to _endStep step _stepSign do {
	sleep _delay;
	_progress = _progress + _stepSize;	
	(uiNamespace getVariable "dzn_ProgressBar") progressSetPosition _progress;
	(uiNamespace getVariable "dzn_ProgressBar") ctrlCommit 0;
};

ctrlDelete (uiNamespace getVariable "dzn_ProgressBar");
