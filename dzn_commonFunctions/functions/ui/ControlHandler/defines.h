
#define COB dzn_AdvDialog2

#define DIALOG_NAME         "dzn_Dynamic_Dialog_Advanced_v2"
#define DIALOG_ID           134801
#define START_CTRL_ID       914500
#define DIALOG_SHOW_TIME    0.15

#define LINE_HEIGHT_OFFSET  0.005
#define SAFEZONE_ASPECT_RATIO (safeZoneH / safeZoneW)

// Defaults
#define BG_COLOR_RGBA        [0,0,0,0.6]
#define HEADER_BG_COLOR_RGBA (["GUI", "BCG_RGB"] call BIS_fnc_displayColorGet)
#define ITEM_BG_COLOR_RGBA   [0,0,0,0.7]
#define NO_BG_COLOR_RGBA     [0,0,0,0]
#define COLOR_ACTIVE_DEFAULT [1,1,1,1]

#define DEFAULT_POS_SIZE    [0, 0, 0.25, 0.1]

#define TEXT_COLOR_RGBA     [1, 1, 1, 1]
#define TEXT_FONT           "PuristaMedium"
#define TEXT_FONT_SIZE      0.04

// Some tackles
#define DEBUG true
#ifdef DEBUG
    #define LOG_PREFIX "(ControlHandler) "
    #define LOG_ diag_log parseText format [LOG_PREFIX +
    #define EOL ]
#else
    #define LOG_PREFIX
    #define LOG_
    #define EOL
#endif

#define Q(X) #X

#define COMPILE_SCRIPT(NAME) compileScript [format ["dzn_commonFunctions\functions\ui\ControlHandler\%1.sqf", Q(NAME)]]
#define PREP_COB_FUNCTION(NAME) [Q(NAME), compileScript [format ["dzn_commonFunctions\functions\ui\ControlHandler\fnc_%1.sqf", Q(NAME)]]]
#define F(NAME) Q(NAME)
#define A(NAME) Q(NAME)

// Attributes
#define L(X) toLowerANSI Q(X)
#define A_TYPE L(type)
#define A_FONT L(font)
#define A_SIZE L(size)
#define A_COLOR L(color)
#define A_COLOR_ACTIVE L(colorActive)
#define A_BG L(bg)
#define A_POS L(pos)
#define A_H L(h)
#define A_W L(w)
#define A_X L(x)
#define A_Y L(y)
#define A_ENABLED L(enabled)
#define A_SHOW L(show)
#define A_TITLE L(title)
#define A_SLIDER_RANGE L(sliderRange)
#define A_VALUE L(value)
#define A_LIST_ELEMENTS L(listElements)
#define A_LIST_VALUES L(listValues)
#define A_ICON L(icon)
#define A_ICON_COLOR L(iconColor)
#define A_ICON_COLOR_ACTIVE L(iconColorActive)
#define A_ICON_RIGHT L(iconRight)
#define A_ICON_RIGHT_COLOR L(iconRightColor)
#define A_ICON_RIGHT_COLOR_ACTIVE L(iconRightColorActive)
#define A_CALLBACK L(callback)
#define A_CALLBACK_ARGS L(callbackArgs)
#define A_TOOLTIP L(tooltip)
#define A_EVENTS L(events)
#define A_TAG L(tag)
#define A_TEXT_RIGHT L(textRight)
#define A_TEXT_RIGHT_COLOR L(textRightColor)
#define A_TEXT_RIGHT_COLOR_ACTIVE L(textRightColorActive)
#define A_CLOSE_BTN L(closeButton)
#define A_ICON_SQUARED L(iconSquared)
#define A_LIST_ITEMS L(listItems)

#define A_X_CALC L(x_calculated)
#define A_Y_CALC L(y_calculated)
#define A_W_CALC L(w_calculated)
#define A_H_CALC L(h_calculated)

#define P_CALLBACK Q(callback)
#define P_CALLBACK_ARGS Q(callbackArgs)
#define P_EH_ID Q(ehid)
#define P_ATTRS Q(attrs)
#define P_HANDLER Q(handler)
#define P_TYPE Q(type)
#define P_TAG Q(tag)
#define P_ISINPUT Q(isInput)
#define P_SUBCONTROL Q(subcontrol)
#define P_RELATED_CHECKBOX Q(relatedCheckbox)
#define P_CUSTOM_TOOLTIP Q(customTooltip)
#define P_LIST_VALUES Q(listValues)

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

#define SET_POSITION(CTRL,ATTRS) \
    LOG_ "[render.Position] By props: x=%1, y=%2, w=%3, h=%4", ATTRS get A_X_CALC, ATTRS get A_Y_CALC, ATTRS get A_W_CALC, ATTRS get A_H_CALC  EOL; \
    CTRL ctrlSetPosition [ \
        ATTRS get A_X_CALC, ATTRS get A_Y_CALC, \
        ATTRS get A_W_CALC, ATTRS get A_H_CALC \
    ]; \
    CTRL ctrlCommit 0

#define SET_COMMON_ATTRIBURES(CTRL,ATTRS) \
    CTRL ctrlSetTextColor (ATTRS get A_COLOR); \
    CTRL ctrlSetFont (ATTRS get A_FONT); \
    CTRL ctrlSetFontHeight (ATTRS get A_SIZE); \
    CTRL ctrlSetBackgroundColor (ATTRS get A_BG); \
    CTRL ctrlSetTooltip (ATTRS getOrDefault [A_TOOLTIP, ""]); \
    CTRL ctrlEnable (ATTRS get A_ENABLED); \
    CTRL ctrlShow (ATTRS get A_SHOW)


#define SET_EVENT_HANDLERS(CTRL,ATTRS,HANDLER) \
    { \
        _x params ["_eventName", "_eventCallback", "_eventCallbackArgs"]; \
        LOG_ "[render.setEventHandlers] Settings EH to %1 for event [%2]", CTRL, _eventName EOL; \
        CTRL ctrlRemoveEventHandler [_eventName, CTRL getVariable [format ["%1_%2", _eventName, P_EH_ID], -1]]; \
        CTRL setVariable [ \
            format ["%1_%2", _eventName, P_EH_ID], \
            CTRL ctrlAddEventHandler [_eventName, HANDLER get F(onEvent)] \
        ]; \
        CTRL setVariable [format ["%1_%2", _eventName, P_CALLBACK], _eventCallback]; \
        CTRL setVariable [format ["%1_%2", _eventName, P_CALLBACK_ARGS], _eventCallbackArgs]; \
    } forEach (ATTRS get A_EVENTS)


#define REGISTER_AS_INPUT _ctrl setVariable [P_ISINPUT, true]

//
#define PICTURE_CLOSE "\a3\3DEN\Data\Displays\Display3DEN\search_end_ca.paa"
