
#include "defines.h"

/*
TODO:
- [] test Dropdown extended syntax
- [] Support X and Y for controls
*/

// COB Definition
private _cob = createHashMapObject [[
    ["#str", { "AdvDialog2_ComponentObject" }],
    [Q(Dialog), nil],
    [Q(DialogAttributes), createHashMapFromArray [
        [A_W, 1],
        [A_H, 1],
        [A_X, 0],
        [A_Y, 0]
    ]],

    [F(OnParsed), {}],
    [Q(OnParsedArgs), []],
    [F(OnDraw), {}],
    [Q(OnDrawArgs), []],

    [Q(Parsers), createHashMap],
    [Q(Renderers), createHashMap],

    [Q(Descriptors), []],
    [Q(Items), []],
    [Q(LineHeights), []],

    // Main functions
    PREP_COB_FUNCTION(ShowDialog),
    PREP_COB_FUNCTION(RegisterControlType),
    PREP_COB_FUNCTION(MergeAttributes),
    PREP_COB_FUNCTION(AppendLinebreak),

    PREP_COB_FUNCTION(reset),
    PREP_COB_FUNCTION(parseParams),
    PREP_COB_FUNCTION(render),

    // Helper functions
    PREP_COB_FUNCTION(GetValueByTag),
    PREP_COB_FUNCTION(GetTaggedValues),
    PREP_COB_FUNCTION(GetValues),
    PREP_COB_FUNCTION(GetByTag),

    PREP_COB_FUNCTION(getControlValue),
    PREP_COB_FUNCTION(onSliderChanged),
    PREP_COB_FUNCTION(onChekboxLabelClicked),
    PREP_COB_FUNCTION(onEvent),
    PREP_COB_FUNCTION(onButtonClick),

    ["#create", {
        // Register types
        {
            [_self] call _x;
        } forEach [
            COMPILE_SCRIPT(registerHeader),
            COMPILE_SCRIPT(registerLabel),
            COMPILE_SCRIPT(registerInput),
            COMPILE_SCRIPT(registerSlider),
            COMPILE_SCRIPT(registerCheckbox),
            COMPILE_SCRIPT(registerListbox),
            COMPILE_SCRIPT(registerButton),
            COMPILE_SCRIPT(registerIconButton)
        ];
    }]
]];

_cob
