/*
	@Marker = [@MarkerName, @MarkerPos, @Icon, @Color, @Text, @IsLocal] call dzn_fnc_createMarkerIcon
	Create marker icon.
	OUTPUT: Marker
*/

params ["_name","_pos","_icon","_color",["_text", ""],["_isLocal", false]];

private ["_mrk"];

if (_isLocal) then {
    _mrk = createMarkerLocal [_name, _pos];
    _mrk setMarkerShapeLocal 'ICON';
    _mrk setMarkerTypeLocal _icon;
    _mrk setMarkerColorLocal _color;
    _mrk setMarkerTextLocal _text;
} else {
    _mrk = createMarker [_name, _pos];
    _mrk setMarkerShape 'ICON';
    _mrk setMarkerType _icon;
    _mrk setMarkerColor _color;
    _mrk setMarkerText _text;
};

_mrk
