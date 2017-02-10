/*
	@Result(Bool) = [
		@Conditions (Array)
		, @CompareOperator (String)
		, @Value (Number)
	] call dzn_fnc_checkUnits;
		
	@Conditions = [
		@Area
		, @Side
		, @Alive (default true)		
		, @CustomCondition		
	]
	
	Templates:
	_result = [ [trg_area, east, "alive"], ">=", 5 ] call dzn_fnc_compareUnits
	
	_result =
	
*/

params["_conditions", ["_operator",">"], ["_value",0]];
#define IFDEFAULT(PAR, VAR1)	if (isNil {_conditions select PAR}) then { VAR1 } else { _conditions select PAR }

private _area = IFDEFAULT(0, objNull);
private _side = IFDEFAULT(1, east);
private _alive = IFDEFAULT(2, "alive");
private _custom = IFDEFAULT(3, "");

private _conditionalString = format [
	"{ %1 
	, if (isNull _area) then { "" } else {
];



_condition count allUnits;

