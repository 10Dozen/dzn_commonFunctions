
/*
 * @Result = ["ADD", @Display, @Tag, @ItemDescriptor] call dzn_fnc_HandleControl;
 * @Result = ["MODIFY", @Display, @Tag, @Attributes, @EventsDescriptor] call dzn_fnc_HandleControl;
 * @Result = ["EXISTS", @Display, @Tag] call dzn_fnc_HandleControl;
 * @Result = ["GetControls", @Display, @Tag] call dzn_fnc_HandleControl;
 * @Result = ["GetValues", @Display, @Tag] call dzn_fnc_HandleControl;
 * @Result = ["REMOVE", @Display, @Tag] call dzn_fnc_HandleControl;
 * @Result = ["RESET", @Display] call dzn_fnc_HandleControl;
 *
 * Creates control at given parent display and then allows to modify and remove it.
 * Tag is required to access controls through function and autogenerates  on creation if not set.
 * Tag is stored in (_ctrl getVariable "tag").
 * See dzn_fnc_ShowAdvDialog2 function for attributes and descriptor syntax, as well as events.
 *
 * Created controls are stored in as a list and as a hashmap (tag-control) of the dzn_ControlHandler object.
 * There are few helper functions to access controls:
 * - Get Control By Tag:
 *      // return all controls created in display
 *      _allControls = _cob call ["GetByTag", [_display, ""]];
 *      // return control with tag "TagName" (true flag for exact match) in display
 *      _controls = _cob call ["GetByTag", [_display, "TagName", true]];
 *      // return all controls in display which tagname starts with "Tag"
 *      _controls = _cob call ["GetByTag", [_display, "Tag*"]];
 * - Get Value By Tag:
 *      _allValues = _cob call ["GetValueByTag", [_display, ""]];
 *      _values = _cob call ["GetValueByTag", [_display, "TagName", true]];
 *      _values = _cob call ["GetValueByTag", [_display, "Tag*"]];
 *
 * INPUT:
 * 0: _mode (STRING)     - one of the following (case insensetive):
 *                         - "ADD" to add new control,
 *                         - "MODIFY" to change attributes/events of previously created control,
 *                         - "GET" to return control at given display by tag,
 *                         - "EXISTS" to check control with given tag exists in given display,
 *                         - "REMOVE" to remove control
 *                         - "RESET" to delete all controls
 * 1: _display (Display) - target display.
 *
 * For "ADD" mode:
 * 2: _tagname (STRING)   - tagname of the control to modify. Tag may be set also as ["tag", "YourTAG"] in attributes.
 *                          May be "" - to use default generated name ("Untagged_TYPE_IDX"). You won't be able to create
 *                          new control with the same tag (you must remove existing control first).
 * 3: _descriptor (ARRAY) - array in item descriptor syntax. See dzn_fnc_ShowAdvDialog2 function for details.
 *
 * For "MODIFY" mode:
 * 2: _tagname (STRING)   - same as above. May be "" - to modify all controls in the display.
 * 3: _attributes (ARRAY) - set of attributes to change.
 * 4: _events (ARRAY)     - set of events to change, in format [_eventName (STRING), _callback (CODE), _callbackArgs(ANY)].
 *                          See dzn_fnc_ShowAdvDialog2 function for details.
 *
 * For "REMOVE" mode:
 * 2: _tagname (STRING)    - same as above.
 *
 * For "EXISTS" mode:
 * 2: _tagname (STRING)    - same as above.
 *
 * FOR "GETCONTROLS" and "GETVALUES" modes:
 * 2: _tagname (STRING)    - tagname or mask (e.g. "My*") to search in given display.
 *
 * OUTPUT:
 *   For "ADD" mode:
 *       CONTROL - create control.
 *   For "MODIFY" mode:
 *       BOOL - false if control was not found by tag.
 *   For "EXISTS" mode:
 *       BOOL - false if control was not found by tag.
 *   For "GETCONTROLS" mode:
 *       ARRAY (of CONTROL) - found controls or empty array if not found.
 *   For "GETVALUES" mode:
 *       HASHMAP (STRINT, ANY) - map of tag-value. For non-input controls value is always `nil`.
 *   For "REMOVE" mode:
 *       BOOL - false if control was not found by tag.
 *   For "RESET" mode:
 *       BOOL - always True
 *
 * CBA EVENTS:
 * Subscribe by:
 *     _ehId = ["dzn_ControlHandler_onControlAdded", { ...event handler code... }] call CBA_fnc_addEventHandler
 *
 * dzn_ControlHandler_onControlAdded - emits on new control rendered.
 *     0: _cob (dzn_ControlHandler hashMapObject) - dzn_ControlHandler component object.
 *     1: _display (DISPLAY) - target display.
 *     2: _control (CONTROL) - created control.
 *
 * dzn_ControlHandler_onControlModified - emits on existed controls modified.
 *     0: _cob (dzn_ControlHandler hashMapObject) - dzn_ControlHandler component object.
 *     1: _display (DISPLAY) - target display.
 *     2: _controls (ARRAY of CONTROL) - list of modiefied controls.
 *     3: _tagname (STRING) - tagname used to select controls.
 * 
 * dzn_ControlHandler_onControlRemoved - emits right before deletion of the selected controls.
 *     0: _cob (dzn_ControlHandler hashMapObject) - dzn_ControlHandler component object.
 *     1: _display (DISPLAY) - target display.
 *     2: _controls (ARRAY of CONTROL) - list of controls.
 *     3: _tagname (STRING) - tagname used to select controls.
 *
  * dzn_ControlHandler_onDisplayReset - emits on display reset.
 *     0: _cob (dzn_ControlHandler hashMapObject) - dzn_ControlHandler component object.
 *     1: _display (DISPLAY) - target display.
 *
 *
 * EXAMPLES:
 * // Add new button control to Map display
 * _ctrl = [
 *     "ADD", (findDisplay 12), "MyTag",
 *     [
 *         "BUTTON",
 *         "REMOVE HEADGEAR!",
 *         { removeHeadgear player },
 *         "Hi!",
 *         [
 *             ["pos", [0.2, 0.2, 0.1, 0.1]]
 *         ],
 *         [["mouseEnter", { hint "On Mouse Enter" }, []]]
 *     ]
 * ] call dzn_fnc_HandleControl;
 *
 * // Modify both attributes and events
 * [
 *     "MODIFY", (findDisplay 12), "MyTag",
 *     [
 *         ["pos", [0.5, 0.5, 0.2, 0.1]],
 *         ["title", "<t align='center'>Test2!</t>"],
 *         ["callback", { hint "Disabled" }]
 *     ],
 *     [
 *         ["mouseEnter", { hint "New text!" }, []],
 *         ["mouseExit", { hint "And new EH!" }, []]
 *     ]
 * ] call dzn_fnc_HandleControl;
 *
 * // Modify only Events of the control - disable previously added EHs
 * [
 *     "MODIFY", (findDisplay 12), "MyTag",
 *     [],
 *     [
 *         ["mouseEnter", nil, nil],
 *         ["mouseExit", nil, nil]
 *     ]
 * ] call dzn_fnc_HandleControl;
 *
 * // Remove control
 * ["Remove", (findDisplay 12), "MyTag"] call dzn_fnc_HandleControl;
 *
*/

#include "ControlHandler\defines.h"

params ["_mode", "_display", "_tagname"];

disableSerialization;
forceUnicode 0;

if (isNil Q(dzn_ControlHandler)) then {
    dzn_ControlHandler = [] call COMPILE_SCRIPT(ComponentObject);
};

private _result = false;
switch (toLowerANSI _mode) do {
    case "add": {
        _this params ["", "", "", ["_itemDescriptor", []]];
        if (_itemDescriptor isEqualTo []) exitWith { forceUnicode -1; nil };
        _result = dzn_ControlHandler call [F(AddControl), [_display, _tagname, _itemDescriptor]]
    };
    case "remove": {
        _result = dzn_ControlHandler call [F(RemoveControl), [_display, _tagname]]
    };
    case "modify": {
        _this params ["", "", "", ["_newAttrs", []], ["_newEvents", []]];
        if (_newAttrs isEqualTo [] && _newEvents isEqualTo [] ) exitWith { forceUnicode -1; nil };
        _result = dzn_ControlHandler call [F(ModifyControl), [_display, _tagname, _newAttrs, _newEvents]];
    };
    case "reset": {
        _result = dzn_ControlHandler call [F(reset), [_display]];
        ["dzn_ControlHandler_onDisplayReset", [dzn_ControlHandler, _display]] call CBA_fnc_localEvent;
    };
    case "exists": {
        private _ctrl = dzn_ControlHandler get Q(TaggedControls) get str(_display) get _tagname;
        _result = (!isNil "_ctrl");
    };
    case "getcontrols": {
        _result = dzn_ControlHandler call [F(GetByTag), [_display, _tagname]]
    };
    case "getvalues": {
        _result = dzn_ControlHandler call [F(GetValueByTag), [_display, _tagname]]
    };
    case "preinit": {
        _result = dzn_ControlHandler call [F(reset), []]
    };
};

forceUnicode -1;

_result