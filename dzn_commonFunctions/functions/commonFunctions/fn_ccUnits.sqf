/*
 * @Result = [@Conditions, @Operator, @Value] call dzn_fnc_ccUnits
 * Count all units in given area (or from all map if list of triggers not passed) and compare with given value via operator.
 * 
 * INPUT:
 * 0: ARRAY - array of conditions in format [@Trigger or @Array of triggers (OBJECT or ARRAY), @Side (SIDE), @Custom conditions (STRING)]
 * 1: STRING - Comparsion operator: "==", "!=", ">", ">=", "<", "<="
 * 2: NUMBER - Number to compare
 * OUTPUT: BOOLEAN
 * 
 * EXAMPLES:
 *      _allEastDead = [[mapTriggers, east], "<", 1] call dzn_fnc_ccUnits;
 *      _unitsInArea = [[base_trg, west], ">=", 3] call dzn_fnc_ccUnits;
 *      _unitsInArea = [[[], west], "==", 1] call dzn_fnc_ccUnits;
 *      
 */

params["_cond", "_operator", "_value"];

private _sideString = format [ "&& side _x == %1", _cond select 1];
private _customString = if (!isNil { _cond select 2 }) then { format [ "&& %1", _cond select 2] } else { "" };

private _area = _cond select 0;
private _areaString = "";

if (typename _area != "ARRAY") then {
	_area = [_area];
};

if !(_area isEqualTo []) then {		
	{
		_areaString = format ["%1 && _x inArea (_area select %2)", _areaString, _forEachIndex];
	} forEach _area;
};

private _condString = format [
	"{ true %1 %2 %3 }"
	, _areaString
	, _sideString
	, _customString
];

call compile format [
	"%1 count allUnits %2 _value"
	, _condString
	, _operator
];
