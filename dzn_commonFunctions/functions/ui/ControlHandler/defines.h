
#define COB dzn_ControlHandler

#define START_CTRL_ID       914500

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
#define DBG_PREFIX Q(ControlHandler)
#define DBG_FUNC_PREFIX __FILE_SHORT__
#define _DBG_PREFIX format ['(%1) [%2] ', DBG_PREFIX, DBG_FUNC_PREFIX]
#define _DBG_FMT diag_log parseText format

#define DEBUG
#ifdef DEBUG
    #define DBG(MSG) _DBG_FMT [_DBG_PREFIX + MSG]
    #define DBG_8(MSG,A1,A2,A3,A4,A5,A6,A7,A8) _DBG_FMT [_DBG_PREFIX + MSG,A1,A2,A3,A4,A5,A6,A7,A8]
    #define DBG_7(MSG,A1,A2,A3,A4,A5,A6,A7) _DBG_FMT [_DBG_PREFIX + MSG,A1,A2,A3,A4,A5,A6,A7]
    #define DBG_6(MSG,A1,A2,A3,A4,A5,A6) _DBG_FMT [_DBG_PREFIX + MSG,A1,A2,A3,A4,A5,A6]
    #define DBG_5(MSG,A1,A2,A3,A4,A5) _DBG_FMT [_DBG_PREFIX + MSG,A1,A2,A3,A4,A5]
    #define DBG_4(MSG,A1,A2,A3,A4) _DBG_FMT [_DBG_PREFIX + MSG,A1,A2,A3,A4]
    #define DBG_3(MSG,A1,A2,A3) _DBG_FMT [_DBG_PREFIX + MSG,A1,A2,A3]
    #define DBG_2(MSG,A1,A2) _DBG_FMT [_DBG_PREFIX + MSG,A1,A2]
    #define DBG_1(MSG,A1) _DBG_FMT [_DBG_PREFIX + MSG,A1]
#else
    #define DBG(MSG)
    #define DBG_8(MSG,A1,A2,A3,A4,A5,A6,A7,A8)
    #define DBG_7(MSG,A1,A2,A3,A4,A5,A6,A7)
    #define DBG_6(MSG,A1,A2,A3,A4,A5,A6)
    #define DBG_5(MSG,A1,A2,A3,A4,A5)
    #define DBG_4(MSG,A1,A2,A3,A4)
    #define DBG_3(MSG,A1,A2,A3)
    #define DBG_2(MSG,A1,A2)
    #define DBG_1(MSG,A1)
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
#define A_ADJUST_HEIGHT L(adjustHeight)

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
        DBG_2("Settings EH to %1 for event [%2]", CTRL, _eventName); \
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
