/*
 * @Result = [@Area, @Side, @CustomCondition, @OperatorAndValue] call dzn_fnc_ccUnits
 * Count all units in given area (or from all map if list of triggers not passed) and compare with given value with operator.
 * OR return list of the units which match conditions
 *
 * INPUT:
 * 0: TRIGGER or List of TRIGGERS or [] - Area to search (1 or several triggers). If [] - all map units will be checked
 * 1: STRING or SIDE - side of units ("west","east","resistance")
 * 2: STRING or CODE - custom conditions where _x is reference to unit ("" or nil if not used). Optional, defaults to "".
 * 3: STRING - comparative operator and value (e.g. "> 4", "== 15"). Optional, defaults to "" - returns list of units.
 * OUTPUT: BOOLEAN or ARRAY
 *
 * EXAMPLES:
 *      _count = [Trg1, "west", "", "< 4"] call dzn_fnc_ccUnits;
 *      _count = [[Trg1,Trg2,Trg3], "resistance", {primaryWeapon _x != ''}, "> 2"] call dzn_fnc_ccUnits
 *      _countAllMapUnits = [[], "west", "", "< 4"] call dzn_fnc_ccUnits;
 *
 *      _list = [[Trg1,Trg2,Trg3], "east", {alive _x}] call dzn_fnc_ccUnits
 */

params["_areas", "_side", ["_cond", "true"], ["_operatorAndValue", ""]];

private _sideConditionStr = format ["side _x == %1", _side];
private _customConditionStr = [_cond, ["CODE"]] call dzn_fnc_stringify;
private _areaConditionStr = "true";

if (_customConditionStr == "") then { _customConditionStr = "true"; };
if !(_areas isEqualType []) then { _areas = [_areas]; };

if (_areas isNotEqualTo []) then {
    private _areaConds = [];
    {
        _areaConds pushBack format ["_x inArea (_areas select %1)", _forEachIndex];
    } forEach _areas;
    _areaConditionStr = _areaConds joinString " || ";
};

private _condString = format [
    "(%1) && { (%2) && (%3) }",
    _sideConditionStr,
    _areaConditionStr,
    _customConditionStr
];

(call compile format [
    [
        "{ %1 } count allUnits %2",    /* count */
        "allUnits select { %1 }"       /* list  */
    ] select (_operatorAndValue == ""),
    _condString,
    _operatorAndValue
])
