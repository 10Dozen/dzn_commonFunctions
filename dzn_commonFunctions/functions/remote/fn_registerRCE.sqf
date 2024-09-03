/*
 * Registers COB as remote accessable. 
 * Also initialize RCE component if not yet initialized.
 * 
 * INPUT:
 * 0: STRING - registration name of the component.
 * 1: HASHMAP - component hashMapObject.
 * 
 * OUTPUT: NULL
 * 
 * EXAMPLES:
 * [
 *    "tSF_CrewOptions",
 *    _crewOptionsCOB
 * ] call dzn_fnc_registerRCE;
 */

#include "RCE\defines.h"
#define RCE_COB COB

LOG_ "(registerRCE) Params: %1", _this EOL;

if (isNil Q(RCE_COB)) then {
    LOG_ "(registerRCE;) Init RCE component" EOL;
    RCE_COB = [] call COMPILE_SCRIPT(ComponentObject);
};

LOG_ "(registerRCE) Invoke RCE component - method 'RegisterComponent'" EOL;
RCE_COB call [F(registerComponent), _this];
