/*
	[(@ViewDistance add), (@ViewObjectDistance add)] call dzn_fnc_addViewDistance
	INPUT:
	0: NUMBER (optional) - step to add view distance
	1: NUMBER (optional) - step to add view object distance
	OUTPUT: Hint with current VS
	
	Increase VD and VOD on given step up to 15000 limit
*/

params [["_vdStep", 1000], ["_vodStep", 400]];

setViewDistance (viewDistance + _vdStep);
setObjectViewDistance [(getObjectViewDistance select 0) + _vodStep, getObjectViewDistance select 1];

hintSilent format [
	"View distance: %1 (%2) m"
	, viewDistance
	, getObjectViewDistance select 0
];
