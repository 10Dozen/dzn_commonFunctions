/*
 * @Result = [@Area, @CustomCondition, @OperatorAndValue] call dzn_fnc_ccPlayers
 * Count all units in given area (or from all map if list of triggers not passed) and compare with given value via operator.
 * OR returns list of the units which match conditions
 *
 * INPUT:
 * 0: TRIGGER or List of TRIGGERS or [] - area to search (1 or several triggers). If [] - all map units will be checked
 * 1: STRING or CODE - custom conditions where _x is reference to unit. Optional, defaults to "true".
 * 2: STRING - comparative operator and value (e.g. "> 4", "== 15"). Optional, defaults to "" - returns list of players.
 * OUTPUT: OUTPUT: BOOLEAN or ARRAY
 *
 * EXAMPLES:
 *      _count = [Trg1, "", "< 4"] call dzn_fnc_ccPlayers;
 *      _count = [[Trg1,Trg2,Trg3], { primaryWeapon _x != "" }, "> 2"] call dzn_fnc_ccPlayers
 *      _countAllMapPlayers = [[], "alive _x", "< 4"] call dzn_fnc_ccPlayers;
 *
 *      _list = [[Trg1,Trg2,Trg3]] call dzn_fnc_ccPlayers
 *      _list = [[Trg1,Trg2,Trg3], {alive _x}] call dzn_fnc_ccPlayers
 */

params ["_areas", ["_cond", "true"], ["_operatorAndValue", ""]];

private _customConditionStr = [_cond, ["CODE"]] call dzn_fnc_stringify;
private _areaConditionStr = "true";

if (typename _areas != "ARRAY") then { _areas = [_areas]; };

if (_areas isNotEqualTo []) then {
    private _areaConds = [];
    {
        _areaConds pushBack format ["_x inArea (_area select %1)", _forEachIndex];
    } forEach _areas;
    _areaConditionStr = _areaConds joinString " || ";
};

private _condString = format [
    "(%1) && (%2)"
    , _areaConditionStr
    , _customConditionStr
];

(call compile format [
	[
		"{ %1 } count (call BIS_fnc_listPlayers) %2",  /* count */
		"(call BIS_fnc_listPlayers) select %1"         /* list  */
	] select (_operatorAndValue == ""),
	_condString,
	_operatorAndValue
])
