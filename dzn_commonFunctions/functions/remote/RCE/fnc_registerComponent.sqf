#include "defines.h"

/*
    Registers component object under it's component name.
    Then reads and executed stored remote calls for this component (if happens).
    Module name is case insensitive.

    (_self)

    Params:
        _componentName (STRING) - name of the component to register.
        _componentObject (HASHMAP) - COB itself.

    Returns:
        nothing

    dzn_RCE call ["fnc_registerComponent", ["FARP", tSF_FARP_Component]];
*/

params ["_componentName", "_componentObject"];

LOG_ "(registerComponent) Params: [%1, %2]", _componentName, _componentObject get "#type" EOL;

_componentName = toLowerANSI _componentName;
(_self get Q(registeredComponents)) set [_componentName, _componentObject];

LOG_ "(registerComponent) Going to handle Queued calls for %1 component", _componentName EOL;
_self call [F(handleStored), [_componentName]];
