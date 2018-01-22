/*
 * @Asset = [@Logic, @Type] call dzn_fnc_selectRandomAsset
 * Selects single asset (bunch of objects synced with single GameLogic or placed inside trigger) from list of synced assets (assets synced to core item or from array), then removes other assets if not needed.
 * 
 * INPUT:
 * 0: GAME LOGIC or ARRAY - Game logic synced with 'asset game logics'/triggers or Array of 'asset game logics'/triggers
 * 1: STRING - Type of removing unselected assets: "None"(default) - do not remove; "All" - remove both objects and markers (for trigger-based assets); "Objects" - remove only objects; "Markers" - remove obly markers (for trigger-based assets);
 * OUTPUT: @OBJECT (Asset)
 * 
 * EXAMPLES:
 *      _asset = [randomAssetLogic, "All"] call dzn_fnc_selectRandomAsset;
 *      _asset2 = [[assetLogic1, assetLogic2], "Markers"] call dzn_fnc_selectRandomAsset
 */	
	
params["_assets", ["_removeType", "none"]];
private _assetLogics = if (typename _assets == "ARRAY") then { _assets } else { synchronizedObjects _logic };
private _selectedAssetLogic = selectRandom _assetLogics;

if (toLower(_removeType) == "none") exitWith { _selectedAssetLogic };
	
private _removeObjects = {
	for "_i" from (count _this - 1) to 0 step -1 do {
		private _obj = _this select _i;		
		{ deleteVehicle _x } forEach ([_obj] + (if (_obj isKindOf "CAManBase") then { [] } else { crew _obj }));
	};	
};
	
_assetLogics = _assetLogics - [_selectedAssetLogic];
{
	private _asset = _x;
	// Trigger
	if (_asset isKindOf "EmptyDetector") then {

		if (toLower(_removeType) in ["all", "markers"]) then {
			{ deleteMarker _x; } forEach (allMapMarkers select {(getMarkerPos _x) inArea _asset});
		};
		if (toLower(_removeType) in ["all", "objects"]) then {	
			( nearestObjects [_asset ,["All"], (triggerArea _asset select 0)] ) call _removeObjects;
		};
	} else {
	// GameLogic
		if (toLower(_removeType) == "markers") exitWith { _selectedAssetLogic };			
		(synchronizedObjects _asset) call _removeObjects;
	};

} forEach _assetLogics;

_selectedAssetLogic	

