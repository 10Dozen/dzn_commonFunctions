// *************************************
// DZN COMMON FUNCTIONS
// v1.8
// *************************************
// Common functions are very common and useful for any missions
// Area functions provide support of creating locations from triggers, getting points and building inside given areas. It is required for DZN_DYNAI
// Base functions are useful to recreate military bases/outposts and compositions using scripts
// Functions to set up time and weather
// Some functions to convert grid to world positinons
// Return display names of items and vehicles
// Some basic UI elements called by scripts (custom overlays, yes/no dialog, dropdown select)
// Fire support functions for Artillery fire
// *************************************

class CfgFunctions
{
    class dzn
    {
        class common
        {
            file = "dzn_commonFunctions\functions\common";

            class getMissionParameters {};
            class getByPath {};
            class setByPath {};
            class getValueByKey {};
            class setValueByKey {};
            class setVars {};
            class selectAndRemove {};
            class runLoop {};
            class report {};

            class assignInVehicle {};
            class createVehicle  {};
            class createVehicleCrew {};
            class isCombatCrewAlive {};
            class getPosOnGivenDir {};
            class getSurfacePos {};

            class getComposition {};
            class setComposition {};

            class inString {};

            class addAction {};
            class playAnimLoop {};

            class setVelocityDirAndUp {};
            class stringify {};
            class parseSFML {};

            class getVersion {};
        };

        class area
        {
            file = "dzn_commonFunctions\functions\area";

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
            class selectRandomAsset {};
        };

        class map
        {
            file = "dzn_commonFunctions\functions\map";

            class createMarkerIcon {};
            class getMapGrid {};
            class getPosOnMapGrid {};
        };

        class env
        {
            file = "dzn_commonFunctions\functions\env";

            class setDateTime {};
            class randomizeTime {};
            class setFog {};
            class setWeather {};
            class addViewDistance {};
            class reduceViewDistance {};
        };

        class inventory
        {
            file = "dzn_commonFunctions\functions\inventory";

            class getItemDisplayName {};
            class getVehicleDisplayName {};
            class addWhitelistedArsenal {};
            class checkClassExists {};
        };

        class support
        {
            file = "dzn_commonFunctions\functions\support";

            class ArtilleryFiremission {};
            class SelectFiremissionCharge {};
            class CancelFiremission {};
            class SpawnShell {};
            class setShellFlareEffect {};
            class setShellFlareEffectGlobal {};
            class StartVirtualFiremission {};
        };

        class ui
        {
            file = "dzn_commonFunctions\functions\ui";

            class CountTextLines {};
            class ShowBasicDialog {};
            class ShowAdvDialog {};
            class ShowAdvDialog2 {};
            class ShowChooseDialog {};

            class HandleControl {};
            class GetDisplay {};

            class ShowMessage {};
            class ShowProgressBar {};

            class AddDraw3d {};
            class RemoveDraw3d {};
        };

        class remote
        {
            file = "dzn_commonFunctions\functions\remote";

            class registerRCE {};
            class RCE {};
            class receiveRCE {};
            class createRCECallback {};
        }
    };
};
