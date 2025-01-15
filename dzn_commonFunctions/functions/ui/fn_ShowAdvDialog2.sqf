/*
    [@Item1, @Item2, ..., @ItenN] call dzn_fnc_ShowAdvDialog2;

    Displays dialog of given structure of labels and inputs.

    Allows to add events to specific controls and read back current values of the inputs.
    Allows to set custom styling for each label/input using attributes (font, text and bg color).
    Labels/buttons/checkboxes support StructuredText syntax.
    Allows to add tooltips for label/input.

    Each control will be placed in the same line as the previous one until ["BR"] item is met.
    Then new line will be filled.
    Controls in the same line will be resized to fill line width in the same proportion.

    Item types and definition:
    Header (stylized label):
        [ 0@Type("HEADER"), 1@Title, 2(optional)@Attributes, 3(optional)@Events ]
    Text label:
        [ 0@Type("LABEL"), 1@Title, 2(optional)@Attributes, 3(optional)@Events ]
    Text input:
        [ 0@Type("INPUT"), 1@DefaultText, 2(optional)@Attributes, 3(optional)@Events ]
        [ 0@Type("INPUT_AREA"), 1@DefaultText, 2(optional)@Attributes, 3(optional)@Events ] 
    Checkbox (left or right-aligned)
        [ 0@Type("CHECKBOX"), 1@Title, 2(optional)@DefaultState, 3(optional)@Attributes, 4(optional)@Events ]
        [ 0@Type("CHECKBOX_RIGHT"), 1@Title, 2(optional)@DefaultState, 3(optional)@Attributes, 4(optional)@Events ]
    Slider:
        [ 0@Type("SLIDER"), 1@[Min, Max, Step], 2(optional)@DefaultPosition, 3(optional)@Attributes, 4(optional)@Events ]
    Dropdown or horizontal options select:
        [ 0@Type("DROPDOWN"), 1@ListItems, 2(optional)@DefaultSelected, 3(optional)@Attributes, 4(optional)@Events ]
        [ 0@Type("LISTBOX"), 1@ListItems, 2(optional)@DefaultSelected, 3(optional)@Attributes, 4(optional)@Events ]
    Button:
        [ 0@Type("BUTTON"), 1@Title, 2@Callback, 3(optional)@Args, 4(optional)@Attributes, 5(optional)@Events ]
    Icon Button:
        [ 0@Type("ICON_BUTTON"), 1@Icon, 2@Callback, 3(optional)@Args, 4(optional)@Attributes, 5(optional)@Events ]
    Line break (used to break current line ):
        ["BR"]
    Dialog settings (used to set up overall dialog box and background)
        [0@Type("DIALOG"), 1@Attributes]

    , where params:
        // Common
        Type (STRING) - "HEADER", "LABEL","BUTTON","DROPDOWN","LISTBOX","CHECKBOX","INPUT","SLIDER"
        Title (STRING) - display text of the element (header, label, checkbox, button)
        Attributes (ARRAY) - (optional) list of extra attributes to be applied
            in format [AttributeName, AttributeValue]. Defaults to [].
            Supported:
              ["font", (STRING)] - name of the font to use. Defaults to 'PuristaLight'.
              ["size", (NUMBER)] - size of the font. Defaults to 0.04.
              ["color", (RGBA ARRAY)] - RGBA color of text. Defaults to [1,1,1,1].
              ["bg", (RGBA ARRAY)] - RGBA color of the control/dialog background. Defaults to [0,0,0,0].
              ["x", (NUMBER)] - position of element/dialog in safezone coordinates. Defaults to 0.
              ["y", (NUMBER)] - position of element/dialog in safezone coordinates. Defaults to 0.
              ["h", (NUMBER)] - item/dialog hieght in safezone coordinates. Defaults to 1 for dialog, for item - "size" attribute is used.
              ["w", (NUMBER)] - item/dialog width in safezone coordinates Defaults to 1 for dialog, for item width will be calculated depending on item count in line.
              ["enabled", (BOOL)] - flag to enable/disable control.
              ["tooltip", (STRING)] - tooltip text for control.
              ["tag", (HASHMAP KEY)] - tag name for the control.
              ["closeButton", (BOOL)] - flag to show close button icon, only for Header. Defaults to true.

        Events (ARRAY) - (optional) list of custom events handlers to be added
              in format [eventName, callbackFunction, callbackArgs].
              Where eventName - see https://community.bistudio.com/wiki/User_Interface_Event_Handlers
              (without 'on' prefix).
              Parameters of the callback function:
                _this # 0 -- event's arguments (see BIKI);
                _this # 1 -- dzn_AdvDialog2 component object to provide useful methods;
                _this # 2 -- callback arguments.

        // Input, Input_area
        DefaultText (STRING) - (optional) input's pre-filled text. Defaults to "".

        // Checkbox, Checkbox_right
        DefaultState (BOOL) - (optional) default state of the checkbox. Defaults to false;

        // Slider
        [Min, Max, Step] (ARRAY of Numbers) - range min-max and precision (e.g. 0.01 for 2 decimals).
        DefaultPosition (NUMBER) - (optional) slider default position. Defaults to range minimum.

        // Dropdown/Listbox
        ListItems (ARRAY of STRINGS) - list of options display names (e.g. ["A", "B", "C"]).
        listItems (ARRAY of [STRING, ANY]) - altervative syntax is an array of arrays
            describing specific items in format:
                0: _itemTitle (STRING) - title of the item;
                1: _itemValue (Anything) - value related to this item;
                2: _itemAttributes (Array of String-Anything pairs) - collection of items attribures:
                 Supported:
                   ["colorActive", (RGBA ARRAY)] - active color (selected) of item text (listbox/dropdown);
                   ["icon", (STRING)] - path to left picture .paa file (listbox/dropdown);
                   ["iconColor", (RGBA ARRAY)] - color of left picture (listbox/dropdown);
                   ["iconColorActive", (RGBA ARRAY)] - color of left picture (listbox/dropdown)
                   ["tooltip", (STRING)] - tooltip for item (dropdown only).
                   ["iconRight", (STRING)] - path to right picture .paa file (dropdown only).
                   ["iconRightColor", (RGBA ARRAY)] - color of right picture (dropdown only).
                   ["iconColorActive", (RGBA ARRAY)] - color of left picture (dropdown only).
                   ["textRight", (STRING)] - right text of item (dropdown only).
                   ["textRightColor", (RGBA ARRAY)] - right text of item (dropdown only).

        DefaultSelected (NUMBER) - (optional) option index selected by default. Defaults to 0.

        // Button
        Callback (CODE) - (optional) callback function to be called on button click event. Defaults to { closeDialog 2 }.
            Parameters:
            _this # 0 - dzn_AdvDialog2 component object to provide useful methods;
            _this # 1 - passed args;
            _this # 2 - button control;
        Args (ANY) - (optional) arguments to be passed into callback function. Defaults to [].

        // Icon button
        Icon (STRING) - path to icon's .paa file.
        Callback (CODE) - see Button.
        Args (ANY) - (optional) see Button.

        === Hooks and events ===
        ["OnParsed", 1@Callback(CODE), 2@Args(ANY)]
            Code to be executed once params parsed, but no dialog rendered.
            Callback params:
            _this # 0 - dzn_AdvDialog2 component object to provide useful methods;
            _this # 1 - passed args;

        ["OnDraw", 1@Callback(CODE), 2@Args(ANY)]
            Code to be executed once dialog is rendered and all control's events are set.
            Callback params:
            _this # 0 - dzn_AdvDialog2 component object to provide useful methods;
            _this # 1 - passed args;

        ["OnCustomEvent", 1@EventName(STRING), 2@Callback(CODE), 3@Args(ANY)]
            Code to be executed on custom CBA event (sent by e.g. CBA_fnc_localEvent).
            Callback params:
            _this - arguments:
                0: _cob - dzn_AdvDialog2 component object to provide useful methods;
                1: _args - passed args
            _thisArgs - Arguments added to event by this function.  <ANY>
            _thisId - Same as the return value of this function.  <NUMBER>
            _thisType - Name of the event.  (Same as _eventName passed to this function) STRING
            _thisFnc - Piece of code added to the event by this function <CODE>

        === Helper functions ===
        Helper function collections (hashMap) may interact with dialog displayed by ShowAdvDialog2 function.
            _values = _cob call ["GetValues"] -- returns an array of current values of the dialog's inputs (listed in the same order as inputs in dialog).
            _valuesMap = _cob call ["GetTaggedValues"] -- return hash map of current values of the dialog's inputs (where key = input tag, and value - current input value).
            _value = _cob call ["GetControlValue", _control] -- returns value of specific control.
            _value = _cob call ["GetValueByTag", _tag] -- returns value of control by given tag.
            Value format depends on input type:
                INPUT:    inputText(String)
                CHECKBOX: isChecked(Bool)
                SLIDER:   [currentPosition(Number), [minRange(Number), maxRange(Number)]]
                DROPDOWN/LISTBOX:
                          [selectedIndex(Number), selectedItemText(String), selectedItemValue(Anything)

            _control = _cob call ["GetByTag", _tag] -- returns control by given tag.
            _controls = _cob call ["GetControls", [_byTag, _byType]] -- returns controls that match given list of types and tags (via AND).
            Where:
                _byTag (ARRAY) list of tags to be found by parial match (e.g. 'time' will find controls tagged as 'time', 'timeLbl', 'timeInput')
                _byType (ARRAY) list of registered types (e.g. "HEADER", "INPUT", "BUTTON")

        Examples:
        // Simple dialog
        [
          ["HEADER", "Hint dialog"],
          ["LABEL", "Hint message"],
          ["INPUT", nil, [["tag", "hintInput"]]],
          ["BR"],
          ["BUTTON", "Show hint", {
            params ["_cob", "_args", "_ctrl"];
            hint (_cob call ["GetValueByTag", "hintInput"])
          }]
        ] call dzn_fnc_ShowAdvDialog2;

        // Complex example 1
        [
          ["HEADER", "Dynamic Advanced Dialog (v2)"],
          ["LABEL", "Select teleport position"],
          ["DROPDOWN", [
            ["Airfield", [0,0,0]],
            ["Mike-26", [100,100,0]],
            ["Kamino Firing Range", [200,200,0]]
          ], nil, [["tag", "tpOption"]]],
          ["BR"],

          ["LABEL", "Hint"],
          ["INPUT", "", [ ["color", [1,1,0,1]], ["tooltip", "Enter hint message"], ["tag", "hintInput"] ]],
          ["BR"],

          ["BUTTON", "Teleport", {
            params ["_cob", "_args"];
            (_cob call ["GetValueByTag", "tpOption"]) params ["_idx", "_tpText", "_tpPos"];

            hint format ["Teleport to %1 (%2)", _tpText, _tpPos];
            player setPos _tpPos;
          }],
          ["BUTTON", "Show hint", {
            params ["_cob", "_args"];
            hint format [
                "Hint message: %1",
                _cob call ["GetValueByTag", "hintInput"]
            ];
          }],
          ["BUTTON", "Spawn vehicle", {
            params ["", "_args"];
            (selectRandom _args) createVehicle position player;
            hint "Spawned!";
          }, ["C_Offroad_01_F", "C_Offroad_02_unarmed_F"]],
          ["BUTTON", "End mission", { hint "Mission Ends soon (it's not)!"}]
        ] call dzn_fnc_ShowAdvDialog2;

        // Complex example 2
        [
          ["HEADER", "Title", nil, [["mouseEnter", { params ["_event", "_cob", "_args"]; hint _args; }, "Mouse Enter Event with Args!"]]],
          ["LABEL", "Text"],
          ["INPUT", "Default text", [["tooltip", "This is a tooltip!"]]],
          ["BR"],
          ["CHECKBOX", "This is a checkbox", nil, [["tooltip", "Some explanation about this checkbox"]]],
          ["CHECKBOX_RIGHT", "This is a checkbox too", true],
          ["BR"],
          ["LISTBOX", ["A", "B", "C"],2],
          ["DROPDOWN", [["A", 100], ["B", 200], ["C", 300]], nil, [["tooltip", "Tooltip for dropdown"]]],
          ["BR"],
          ["LABEL", "Stylized text", [["color", [1,1,0,1]], ["size", 0.1]]],
          ["SLIDER", [0,100,0.01], 50, [["tooltip", "Kek lol"]]],
          ["BR"],
          ["BUTTON", "Close"],
          ["BUTTON", "<t align='center'>Do something</t>", { hint str(_this); diag_log _this }, "KEK LOL"]
       ] call dzn_fnc_ShowAdvDialog2

*/

#include "AdvDialog2\defines.h"

disableSerialization;
forceUnicode 0;

if (isNil Q(dzn_AdvDialog2)) then {
    dzn_AdvDialog2 = [] call COMPILE_SCRIPT(ComponentObject);
};

if (_this isEqualTo []) exitWith { forceUnicode -1; };

if (!isNil { dzn_AdvDialog2 get Q(Dialog) }) exitWith {
    forceUnicode -1;

    dzn_AdvDialog2 call [F(Close)];
    [{        
        dzn_AdvDialog2 call [F(ShowDialog), _this];
    }, _this] call CBA_fnc_execNextFrame;
};

dzn_AdvDialog2 call [F(ShowDialog), _this];
forceUnicode -1;
