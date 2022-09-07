
#include "script_component.hpp"
#define TEST test1_ShowSWMessages


// Test
sleep 1;
["Show", ["SW", "Bird-1", "RTB, Over'n'out"]] call tSF_Chatter_fnc_MessageRenderer;

sleep 2;
["Show", ["LR", "Bird-2", "RTB, Over'n'out"]] call tSF_Chatter_fnc_MessageRenderer;


sleep 2;
["Show", ["SW", "Bird-3", "RTB, Over'n'out"]] call tSF_Chatter_fnc_MessageRenderer;

["Clear"] call tSF_Chatter_fnc_MessageRenderer;
