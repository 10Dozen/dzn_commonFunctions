#include "defines.h"

params [];

if (
    isNull (_self get Q(Dialog))
    && !(_self get Q(Closed))
) exitWith {
    DBG("Going to invoke close by missiong dialog...");
    _self call [F(Close), [true]];
};
