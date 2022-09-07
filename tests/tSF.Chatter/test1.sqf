
#include "script_component.hpp"
#define TEST test1_ShowLRMessages


// Test
sleep 1;
["Show", ["LR", "Bird-1", "RTB, Over'n'out"]] call tSF_Chatter_fnc_MessageRenderer;

sleep 2;
["Show", ["LR", "Bird-2", "RTB, Over'n'out"]] call tSF_Chatter_fnc_MessageRenderer;


sleep 2;
["Show", ["LR", "Bird-3", "RTB, Over'n'out"]] call tSF_Chatter_fnc_MessageRenderer;


sleep 2;
["Show", ["LR", "Bird-4", "RTB, Over'n'out"]] call tSF_Chatter_fnc_MessageRenderer;
