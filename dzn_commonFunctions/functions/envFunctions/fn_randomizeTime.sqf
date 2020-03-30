/*
 * _date = [_initDate, _range] call dzn_fnc_randomizeTime
 * _date = [_initDate, _namedRange] call dzn_fnc_randomizeTime
 * _date = [_initDate, _index] call dzn_fnc_randomizeTime
 * _date = [_initDate, _index, [_namedRange1, _namedRange2, ..., _namedRangeN]] call dzn_fnc_randomizeTime
 * _date = [_initDate, _index, [_range1, _range2, ..., _rangeN]] call dzn_fnc_randomizeTime
 *
 * Randomizes given date's time according to provided options. 
 *      
 *      Depending on 2nd parameter, randomization may be applied differently:
 *      (a) Range array [min, max] - selects random from (min) to (max), e.g. [12, 16] -> 12:00...15:50, [23, 2] -> 23:00...1:50, [2, 23] -> 2:00 -> 22:50
 *      (b) Named range (string) - selects random from named range, calculated from sunrise/sunset time, valid options: "day", "night", "morning", "midday", "evening", "midnight", "random"; e.g. "night" -> approx. 20:00...5:50, "morning" -> approx. 6:00...9:55; invalid names falls back to "random" -> 0:00...23:50;
 *      (c) Range index (number) - index to select from named ranges or from provided ranges (named or range array), used to provide support for mission parameter; e.g.:
 *        - index 1 with no range provided (defaults used) -> "night", approx. 20:00...5:50; 
 *        - index 2 with provided ["day","night","morning"] -> "morning", approx. 6:00...9:55;
 *        - index 0 with provided [[0,3], [20,23]] -> [0,3], 0:00...2:50
 *      
 * INPUT:
 * 0: ARRAY of date [YYYY,MM,DD,HH,mm] - Initial date (same as date command returns)
 * 1: ARRAY of 2 numbers OR STRING OR NUMBER - (optional) Range to randomize OR Named range (see desc.) OR range index. Default: [0,24]
 * 2: ARRAY of ranges - (optional) list of ranges [min,max] or named ranges ["day","night"]. Default: ["day", "night", "morning", "midday", "evening", "midnight", "random"]
 * OUTPUT: ARRAY of date [YYYY,MM,DD,HH,mm] - date with randomized time
 * 
 * EXAMPLES:
 *      _date = [date] call dzn_fnc_randomizeTime; // [2020,03,30,06,20]
 *      _date = [date, [10,14]] call dzn_fnc_randomizeTime; // [2020,03,30,12,45]
 *      _date = [date, "night"] call dzn_fnc_randomizeTime; // [2020,03,30,03,15]
 *      
 *      _date = [date, par_daytime, [[9,16], [21, 5], [0,24]]] call dzn_fnc_randomizeTime; // for par_daytime = 0 select from [9,16] range -> [2020,03,30,15,45]
 *      _date = [date, par_daytime, ["day","night","random"]] call dzn_fnc_randomizeTime; // for par_daytime = 1 select from night (depending on sunshine and sunrise time) -> [2020,03,30,22,00]
 *      
 *      _date = [date, par_daytime] call dzn_fnc_randomizeTime; // for par_daytime = 3 select from morning range -> [2020,03,30,08,45]
 *      
 */
params ["_date", ["_mode", [0,24]], ["_rangeList", ["day","night","morning","midday","evening","midnight","random"]]];

private "_range";
switch (typename _mode) do {
	case (typename 0): {
		_range = _rangeList # _mode;
	};
	case (typename []): {
		_range = +_mode;
	};
	case (typename ""): {
		_range = _mode;
	};
};

if (_range isEqualType "") then {
	(_date call BIS_fnc_sunriseSunsetTime) params ["_sunrise","_sunset"];
	_sunrise = ceil _sunrise;
	_sunset = floor _sunset;
	private _deltaDay = _sunset - _sunrise;
	private _deltaNight = 24 + _sunrise - _sunset;

	_range = switch _range do {
		case "day": { [_sunrise + 2, _sunset - 2] };
		case "night": { [_sunset + 2, _sunrise - 2] };
		case "morning": { [_sunrise, floor(_sunrise + 0.35*_deltaDay)] };
		case "midday": { [ceil(_sunrise + 0.35*_deltaDay),floor(_sunrise + 0.65*_deltaDay)] };
		case "evening": { [ceil(_sunrise + 0.65*_deltaDay) , _sunset] };
		case "midnight": { [ceil(_sunset + 0.35*_deltaNight), floor(_sunset + 0.75*_deltaNight)] };
		default { [0,24] };
	};
};

_range params ["_min","_max"];
if (_min > _max) then { _max = _max + 24; };

private _hours = _min + (0 max round random (_max - _min - 1));
if (_hours > 23) then { _hours = _hours - 24; };
private _minutes = selectRandom [0,10,15,20,25,30,40,45,50];

[_date # 0, _date # 1, _date # 2, 0 max _hours, _minutes]
