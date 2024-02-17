
#define COB dzn_AdvDialog2

#define DIALOG_NAME         "dzn_Dynamic_Dialog_Advanced_v2"
#define DIALOG_ID           134801
#define START_CTRL_ID       14500
#define DIALOG_SHOW_TIME    0.15

#define LINE_HEIGHT_OFFSET  0.005
#define SAFEZONE_ASPECT_RATIO (safeZoneH / safeZoneW)

// Defaults
#define BG_COLOR_RGBA        [0,0,0,0.6]
#define HEADER_BG_COLOR_RGBA [0.77, 0.51, 0.08, 0.8]
#define ITEM_BG_COLOR_RGBA   [0,0,0,0.7]
#define NO_BG_COLOR_RGBA     [0,0,0,0]

#define TEXT_COLOR_RGBA     [1, 1, 1, 1]
#define TEXT_FONT           "PuristaLight"
#define TEXT_FONT_SIZE      0.04


// Some tackles

//#define DEBUG true
#ifdef DEBUG
    #define LOG_PREFIX "(AdvDialog2) "
    #define LOG_ diag_log parseText format [LOG_PREFIX +
    #define EOL ]
#else
    #define LOG_PREFIX
    #define LOG_
    #define EOL
#endif

#define Q(X) #X

#define COMPILE_SCRIPT(NAME) compileScript [format ["dzn_commonFunctions\functions\ui\AdvDialog2\%1.sqf", Q(NAME)]]
#define PREP_COB_FUNCTION(NAME) [Q(NAME), compileScript [format ["dzn_commonFunctions\functions\ui\AdvDialog2\fnc_%1.sqf", Q(NAME)]]]
#define F(NAME) Q(NAME)
#define A(NAME) Q(NAME)

// Attributes
#define A_TYPE "type"
#define A_FONT "font"
#define A_SIZE "size"
#define A_COLOR "color"
#define A_COLOR_ACTIVE "colorActive"
#define A_BG "bg"
#define A_H "h"
#define A_W "w"
#define A_X "x"
#define A_Y "y"
#define A_ENABLED "enabled"
#define A_TITLE "title"
#define A_SLIDER_RANGE "sliderRange"
#define A_SELECTED "selected"
#define A_LIST_ELEMENTS "listElements"
#define A_LIST_VALUES "listValues"
#define A_ICON "icon"
#define A_ICON_COLOR "iconColor"
#define A_ICON_COLOR_ACTIVE "iconColorActive"
#define A_ICON_RIGHT "iconRight"
#define A_ICON_RIGHT_COLOR "iconRightColor"
#define A_ICON_RIGHT_COLOR_ACTIVE "iconRightColorActive"
#define A_CALLBACK "callback"
#define A_CALLBACK_ARGS "callbackArgs"
#define A_TOOLTIP "tooltip"
#define A_EVENTS "events"
#define A_TAG "tag"
#define A_TEXT_RIGHT "textRight"
#define A_TEXT_RIGHT_COLOR "textRightColor"


// Control classes
#define RSC_GROUP "RscControlsGroupNoScrollbars"
#define RSC_BUTTON_PICTURE "ctrlButtonPictureKeepAspect"
#define RSC_BG "RscText"
#define RSC_HEADER "RscStructuredText"
#define RSC_LABEL "RscStructuredText"
#define RSC_INPUT "RscEdit"
#define RSC_INPUT_AREA "RscEditMulti"
#define RSC_SLIDER "RscXSliderH"
#define RSC_DROPDOWN "RscCombo"
#define RSC_LISTBOX "RscXListBox"
#define RSC_CHECKBOX "RscCheckbox"
#define RSC_BUTTON "RscButtonMenuOK"


// Types registration/Parser/Render
#define PARSING_APPLY_ATTRIBUTES _cob call [F(MergeAttributes), [_item, _attrs]]

#define SET_POSITION(CTRL, X, Y, W, H) \
    LOG_ "[render.setPosition] x=%1, y=%2, w=%3, h=%4", X, Y, W, H EOL; \
    CTRL ctrlSetPosition [X,Y,W,H]; \
    CTRL ctrlCommit 0

#define SET_ATTRIBURES(CTRL) \
    CTRL ctrlSetTextColor (_item get A_COLOR); \
    CTRL ctrlSetFont (_item get A_FONT); \
    CTRL ctrlSetFontHeight (_item get A_SIZE); \
    CTRL ctrlSetBackgroundColor (_item get A_BG); \
    CTRL ctrlSetTooltip (_item getOrDefault [A_TOOLTIP, ""])

#define SET_EVENTS(CTRL) \
    { \
        _x params ["_eventName", "_eventCallback", "_eventCallbackArgs"]; \
        LOG_ "[render.AddEvent] Adding _eventName=%1, _callback=%2, _args=%3", _eventName, _eventCallback, _eventCallbackArgs EOL; \
        CTRL setVariable [format ["%1_%2", _eventName, A_CALLBACK], _eventCallback]; \
        CTRL setVariable [format ["%1_%2", _eventName, A_CALLBACK_ARGS], _eventCallbackArgs]; \
        CTRL ctrlAddEventHandler [_eventName, _cob get F(onEvent)]; \
    } forEach (_item get A_EVENTS)


#define REGISTER_AS_INPUT _ctrl setVariable [Q(isInput), true]

//
#define PICTURE_CLOSE "\a3\3DEN\Data\Displays\Display3DEN\search_end_ca.paa"
