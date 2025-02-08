
#define COB dzn_AdvDialog2

#define DIALOG_NAME         "dzn_Dynamic_Dialog_Advanced_v2"
#define DIALOG_ID           134801
#define START_CTRL_ID       14500
#define DIALOG_SHOW_TIME    0.15

#define LINE_HEIGHT_OFFSET  0.005
#define SAFEZONE_ASPECT_RATIO (safeZoneH / safeZoneW)

// Defaults
#define BG_COLOR_RGBA        [0,0,0,0.6]
#define HEADER_BG_COLOR_RGBA (["GUI", "BCG_RGB"] call BIS_fnc_displayColorGet)
#define ITEM_BG_COLOR_RGBA   [0,0,0,0.9]
#define NO_BG_COLOR_RGBA     [0,0,0,0]

#define TEXT_COLOR_RGBA     [1, 1, 1, 1]
#define TEXT_FONT           "PuristaMedium"
#define TEXT_FONT_SIZE      0.04

// Some tackles
//#define DEBUG true

#define DBG_PREFIX Q(AdvDialog2)
#define DBG_FUNC_PREFIX __FILE_SHORT__
#define _DBG_PREFIX format ['(%1) [%2] ', DBG_PREFIX, DBG_FUNC_PREFIX]
#define _DBG_FMT diag_log parseText format

//#define DEBUG
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

#define COMPILE_SCRIPT(NAME) compileScript [format ["dzn_commonFunctions\functions\ui\AdvDialog2\%1.sqf", Q(NAME)]]
#define PREP_COB_FUNCTION(NAME) [Q(NAME), compileScript [format ["dzn_commonFunctions\functions\ui\AdvDialog2\fnc_%1.sqf", Q(NAME)]]]
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
#define A_H L(h)
#define A_W L(w)
#define A_X L(x)
#define A_Y L(y)
#define A_ENABLED L(enabled)
#define A_TITLE L(title)
#define A_SLIDER_RANGE L(sliderRange)
#define A_SELECTED L(selected)
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

#define A_DIALOG_SHOW_TIME L(dialogShowTime)
#define A_DIALOG L(dialog)

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

#define GET_OR(ITEM,KEY,DEF) ITEM getOrDefault [KEY,DEF]
#define SET_POSITION(CTRL, ITEM, X, Y, W, H) \
    DBG_4("Position - Auto: x=%1, y=%2, w=%3, h=%4", X, Y, W, H); \
    DBG_4("Position - prop: x=%1, y=%2, w=%3, h=%4", GET_OR(ITEM,A_X,X), GET_OR(ITEM,A_Y,Y), W, H); \
    CTRL ctrlSetPosition [ \
        ITEM getOrDefault [A_X, X], ITEM getOrDefault [A_Y, Y], \
        W, H \
    ]; \
    CTRL ctrlCommit 0

#define SET_ATTRIBURES(CTRL) \
    CTRL ctrlSetTextColor (_item get A_COLOR); \
    CTRL ctrlSetFont (_item get A_FONT); \
    CTRL ctrlSetFontHeight (_item get A_SIZE); \
    CTRL ctrlSetBackgroundColor (_item get A_BG); \
    CTRL ctrlSetTooltip (_item getOrDefault [A_TOOLTIP, ""])

#define SET_EVENTS(CTRL) \
    CTRL setVariable [Q(DialogCOB), _self]; \
    { \
        _x params ["_eventName", "_eventCallback", "_eventCallbackArgs"]; \
        DBG_3("Add event: _eventName=%1, _callback=%2, _args=%3", _eventName, _eventCallback, _eventCallbackArgs); \
        CTRL setVariable [format ["%1_%2", _eventName, A_CALLBACK], _eventCallback]; \
        CTRL setVariable [format ["%1_%2", _eventName, A_CALLBACK_ARGS], _eventCallbackArgs]; \
        CTRL ctrlAddEventHandler [_eventName, _cob get F(onEvent)]; \
    } forEach (_item get A_EVENTS)


#define REGISTER_AS_INPUT _ctrl setVariable [Q(isInput), true]

//
#define PICTURE_CLOSE "\a3\3DEN\Data\Displays\Display3DEN\search_end_ca.paa"
