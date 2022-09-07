/*
 * @Asset = [@Logic, @Type] call dzn_fnc_selectRandomAsset
 * Selects single asset (bunch of objects synced with single GameLogic or placed inside trigger) from list of synced assets (assets synced to core item or from array), then removes other assets if not needed.
 * Place composition and use any of approaches below:
 *	a) Sync all objects with GameLogic, then sync GameLogics from several composition to one core GameLogic (which will be used in function call)
 *	b) Place trigger, that covers composition and markers you want to remove, sync trigger to one core GameLogic (which will be used in function call)
 *
 * INPUT:
 * 0: GAME LOGIC or ARRAY - Game logic synced with 'asset game logics'/triggers or Array of 'asset game logics'/triggers
 * 1: STRING - Type of removing unselected assets: "None"(default) - do not remove; "All" - remove both objects and markers (for trigger-based assets); "Objects" - remove only objects; "Markers" - remove obly markers (for trigger-based assets);
 * OUTPUT: @OBJECT (AssetLogic/Trigger)
 * 
 * EXAMPLES:
 *      _asset = [randomAssetLogic, "All"] call dzn_fnc_selectRandomAsset;
 *      _asset2 = [[assetLogic1, assetLogic2], "Markers"] call dzn_fnc_selectRandomAsset
 */	
	
params["_assets", ["_removeType", "none"]];
private _assetLogics = if (typename _assets == "ARRAY") then { _assets } else { synchronizedObjects _assets };
private _selectedAssetLogic = selectRandom _assetLogics;

_removeType = toLower(_removeType);
if (_removeType == "none") exitWith { _selectedAssetLogic };
	
private _removeObjects = {
	for "_i" from (count _this - 1) to 0 step -1 do {
		private _obj = _this # _i;		
		private _toRemove = ([_obj] + (if (_obj isKindOf "CAManBase") then { [] } else { crew _obj }));
		
		{ deleteVehicle _x; } forEach _toRemove;
	};	
};
	
// --- Removing all assets except selected	
_assetLogics = _assetLogics - [_selectedAssetLogic];
{
	private _asset = _x;
	// --- Trigger
	if (_asset isKindOf "EmptyDetector") then {
		if (_removeType in ["all", "markers"]) then {
			{ deleteMarker _x; } forEach (allMapMarkers select {(getMarkerPos _x) inArea _asset});
		};
		if (_removeType in ["all", "objects"]) then {	
			( nearestObjects [_asset ,["All"], (triggerArea _asset select 0)] ) call _removeObjects;
		};
	} else {
	//---  GameLogic
		if (_removeType == "markers") exitWith { _selectedAssetLogic }; // Can not be done
		(synchronizedObjects _asset) call _removeObjects;
	};

} forEach _assetLogics;

_selectedAssetLogic	
