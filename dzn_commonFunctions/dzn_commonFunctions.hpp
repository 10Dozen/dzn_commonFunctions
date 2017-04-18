// *************************************
// DZN COMMON FUNCTIONS
//
// Settings
// To disable unused fucntions - comment next values
// *************************************

// Common functions are very common and useful for any missions
#define	COMMON_FUNCTIONS	true
// Area functions provide support of creating locations from triggers, getting points and building inside given areas. It is required for DZN_DYNAI
#define	AREA_FUNCTIONS		true
// Base functions are useful to recreate military bases/outposts and compositions using scripts
#define BASE_FUNCTIONS		true
// Functions to set up time and weather
#define	ENV_FUNCTIONS		true
// Some functions to convert grid to world positinons
#define	MAP_FUNCTIONS		true
// Return display names of items and vehicles
#define	INV_FUNCTIONS		true
// Some basic UI elements called by scripts (custom overlays, yes/no dialog, dropdown select)
#define	UI_FUNCTIONS			true
// Fire support functions
#define	SUP_FUNCTIONS		true

class CfgFunctions
{
	class dzn
	{
		#ifdef COMMON_FUNCTIONS
		class commonFunctions
		{
			file = "dzn_commonFunctions\functions\commonFunctions";
			
			class getMissionParametes {};
			class getValueByKey {};
			class setValueByKey {};	
			class setVars {};
			class selectAndRemove {};

			class assignInVehicle {};
			class createVehicle  {};
			class createVehicleCrew {};
			class isCombatCrewAlive {};
			class getPosOnGivenDir  {};
			
			class getComposition {};
			class setComposition {};
			
			class inString {};
			
			class addAction {};
			class playAnimLoop {};
			
			class setVelocityDirAndUp {};
			class stringify {};
		};
		#endif
		
		#ifdef AREA_FUNCTIONS
		class areaFunctions
		{
			file = "dzn_commonFunctions\functions\areaFunctions";
			
			class convertTriggerToLocation {};
			class isInLocation {};
			class isInWater {};
			class isInArea2d {};
			
			class isPlayerNear {};
			class isPlayerInArea {};
			class ccUnits {};
			class ccPlayers {};
			
			class getRandomPoint {};
			class getRandomPointInZone {};
			class getZonePosition {};
			class createPathFromKeypoints {};
			class createPathFromRandom {};
			class createPathFromRoads {};
			
			class getHousesNear {};	
			class getHousePositions {};
			class getLocationBuildings {};
			class getLocationRoads {};
			class assignInBuilding {};
		};
		#endif	

		#ifdef MAP_FUNCTIONS
		class mapFunctions
		{
			file = "dzn_commonFunctions\functions\mapFunctions";
			
			class createMarkerIcon {};
			class getMapGrid {};
			class getPosOnMapGrid {};
		};
		#endif
		
		#ifdef ENV_FUNCTIONS
		class envFunctions
		{
			file = "dzn_commonFunctions\functions\envFunctions";
			
			class setDateTime {};
			class setFog {};
			class setWeather {};
			class addViewDistance {};
			class reduceViewDistance {};
		};
		#endif
		
		#ifdef INV_FUNCTIONS
		class invFunctions
		{
			file = "dzn_commonFunctions\functions\invFunctions";
			
			class getItemDisplayName {};
			class getVehicleDisplayName {};
			class addWhitelistedArsenal {};
		};
		#endif
		
		#ifdef SUP_FUNCTIONS
		class supportFunctions
		{
			file = "dzn_commonFunctions\functions\supportFunctions";
			
			class ArtilleryFiremission {};
			class SelectFiremissionCharge {};
			class CancelFiremission {};
		};
		#endif
		
		#ifdef UI_FUNCTIONS
		class uiFunctions
		{
			file = "dzn_commonFunctions\functions\uiFunctions";
			
			class CountTextLines {};
			class ShowBasicDialog {};
			class ShowAdvDialog {};
			class ShowChooseDialog {};
			
			class ShowMessage {};			
			class ShowProgressBar {};
			
			class AddDraw3d {};
			class RemoveDraw3d {};
		};
		#endif
	};
};
