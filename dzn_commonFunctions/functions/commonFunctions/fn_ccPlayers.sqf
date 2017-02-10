/*
 * @Result = [@Conditions, @Operator, @Value] call dzn_fnc_ccPlayers
 * Count all units in given area (or from all map if list of triggers not passed) and compare with given value via operator.
 * 
 * INPUT:
 * 0: ARRAY - array of conditions in format [@Trigger or @Array of triggers (OBJECT or ARRAY), @Custom conditions (STRING)]
 * 1: STRING - Comparsion operator: "==", "!=", ">", ">=", "<", "<="
 * 2: NUMBER - Number to compare
 * OUTPUT: BOOLEAN
 * 
 * EXAMPLES:
 *      _noPlayersInArea = [[mapTriggers], "<", 1] call dzn_fnc_ccPlayers;
 *      _playersWithGuns = [[base_trg, "primaryWeapon _x != ''"], ">=", 3] call dzn_fnc_ccPlayers;
 *      _anyAlivePlayer = [[[]], "==", 1] call dzn_fnc_ccPlayers;
 *      
 */

params["_cond", "_operator", "_value"];

private _customString = if (!isNil { _cond select 1 }) then { format [ "&& %1", _cond select 2] } else { "" };

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
	"{ true %1 %2 }"
	, _areaString
	, _customString
];

call compile format [
	"%1 count (call BIS_fnc_listPlayers) %2 _value"
	, _condString
	, _operator
];
