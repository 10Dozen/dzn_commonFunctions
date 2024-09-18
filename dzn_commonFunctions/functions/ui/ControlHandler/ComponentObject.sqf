#include "defines.h"

// COB Definition
private _cob = createHashMapObject [[
    ["#str", { "ControlHandler_ComponentObject" }],

    [Q(Parsers), createHashMap],
    [Q(Creators), createHashMap],
    [Q(Renderers), createHashMap],
    [Q(Removers), createHashMap],

    [Q(Controls), createHashMap],
    [Q(TaggedControls), createHashMap],
    [Q(ControlIndex), 0],

    // Main functions
    PREP_COB_FUNCTION(AddControl),
    PREP_COB_FUNCTION(RemoveControl),
    PREP_COB_FUNCTION(ModifyControl),
    PREP_COB_FUNCTION(RegisterControlType),
    PREP_COB_FUNCTION(MergeAttributes),

    PREP_COB_FUNCTION(reset),
    PREP_COB_FUNCTION(parseParams),
    PREP_COB_FUNCTION(render),

    // Helper functions
    PREP_COB_FUNCTION(GetByTag),
    PREP_COB_FUNCTION(GetValueByTag),

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
