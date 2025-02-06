#include "defines.h"

/*
    Parses given line according to current mode

    Params:
	0: () - ??

    Returns:
    nothing
*/

if (_mode != MODE_MULTILINE_TEXT && _line == EOF) exitWith {};

switch _mode do {
    case MODE_ROOT: {
        if (_actualIndent != 0) exitWith {
            DBG_1("(ROOT) [ERROR:ERR_INDENT_UNEXPECTED_ROOT] Error - unexpected indent: %1", _actualIndent);
            REPORT_ERROR(ERR_INDENT_UNEXPECTED_ROOT, _forEachIndex, "Unexpected indent on parsing root element")
        };

        DBG_1("(ROOT) Line: [%1]", _line);
        private _parsed = _self call ["parseKeyValuePair", [_line]];
        DBG_1("(ROOT) Parsed: %1", _parsed);
        if (_parsed isEqualTo []) exitWith {
            DBG_1("(ROOT) [ERROR:ERR_DATA_MALFORMED] Unknown markup at index: %1", _forEachIndex);
            REPORT_ERROR(ERR_DATA_MALFORMED, _forEachIndex, "Unknown markup in line (not a key-value pair/section/array)");
        };
        _parsed params ["_key", "_value"];

        // Object found
        if (_value isEqualTo "") exitWith {
            dzn_SFML call ["addNode", [_key]];
            _mode = MODE_NESTED;
            DBG("(ROOT) #PARSED# Is start of the section. Switching to MODE_NESTED");
        };

        // Multiline text is found - add node and switch to multiline mode
        if (IS_MULTILINE_START(_value)) exitWith {
            DBG("(ROOT) #PARSED# Start of the multiline text section. Switching to MODE_MULTILINE_TEXT");
            _mode = MODE_MULTILINE_TEXT;
            _self call ["initMultilineBuffer", [_key, _actualIndent, _value]];
        };

        // Simple key-value pair
        DBG("(ROOT) #PARSED# Adding key-value pair to hash.");
        _self call ["addSetting", [_key, _value]];
    };
    case MODE_MULTILINE_TEXT: {
        private _expectedIndent = _hash get MULTILINE_INDENT_NODE;
        if (_actualIndent < _expectedIndent) exitWith {
            DBG("(MULTILINE) End of the multiline text.");

            // Saving multiline data

            private _key = _hash get MULTILINE_KEY_NODE;
            private _linesList = _hash get MULTILINE_VALUE_NODE;

            // Clean tailing empty lines
            for "_i" from (count _linesList - 1) to 0 step -1 do {
                if (_linesList # _i == "") then {
                    _linesList deleteAt _i;
                } else {
                    break;
                };
            };
            // Compose lines according to selected mode
            private _value = switch (_hash get MULTILINE_MODE_NODE) do {
                case MULTILINE_MODE_NEWLINES: { _linesList joinString endl };
                case MULTILINE_MODE_FOLDED: { _linesList joinString " " };
                case MULTILINE_MODE_CODE: { compile (_linesList joinString endl) };
            };
            DBG_2("(MULTILINE) Key: %1, Composed: %2", _key, _value);

            if (_key isEqualTo "") then {
                // Multiline in array item
                private _arrayKey = _self call ["addArrayItem", [_value, false]];
                DBG_1("(MULTILINE.ARRAY) Simple array item added with index %1", _arrayKey);
            } else {
                // Multiline in key
                _self call ["addSetting", [_key, _value, false]];
                DBG_1("(MULTILINE.PAIR) Added to key %1", _key);
            };

            // Drop multiline buffer
            _hash deleteAt MULTILINE_KEY_NODE;
            _hash deleteAt MULTILINE_VALUE_NODE;
            _hash deleteAt MULTILINE_INDENT_NODE;
            _hash deleteAt MULTILINE_MODE_NODE;

            // Change mode of the parser
            if (_actualIndent == 0) then {
                DBG("(MULTILINE) Returning to MODE_ROOT");
                _hashNodesRoute = [];
                _mode = MODE_ROOT;
            } else {
                DBG("(MULTILINE) Returning to MODE_NESTED");
                _mode = MODE_NESTED;
            };
            _self call ["parseLine", []];
        };

        // Trim left for a number of the expected indent chars
        private _trimmed = _line select [_expectedIndent, count _line];
        DBG_1("(MULTILINE) Adding trimmed line [%1] to buffer", _trimmed);
        (_hash get MULTILINE_VALUE_NODE) pushBack _trimmed;
    };
    case MODE_NESTED: {
        if (_actualIndent == 0) exitWith {
            DBG("(NESTED) End of the all nested objects");
            _hashNodesRoute = [];
            _mode = MODE_ROOT;
            _self call ["parseLine", []];
        };

        if (_actualIndent % 2 > 0) exitWith {
            DBG_1("(NESTED) [ERROR:ERR_INDENT_MALFORMED] Indent malformed (%1 is not a multiple of 2)", _actualIndent);
            REPORT_ERROR(ERR_INDENT_MALFORMED, _forEachIndex, "Indent malformed (not a multiple of 2)");
        };

        private _calculated = _self call ["calculateExpectedIndent",[]];
        private _indentDiff = _calculated - _actualIndent;

        DBG_2("(NESTED) Calcualted indent: %1 (diff: %2)", _calculated, _indentDiff);

        private _closedCount = ceil (_indentDiff / INDENT_DEFAULT);
        if (_indentDiff < 0 || (_indentDiff > 0 && _closedCount == 0)) exitWith {
            DBG_2("(NESTED) [ERROR:ERR_INDENT_UNEXPECTED_NESTED] Unexpected indent for nested item (expected %1, but actual is %2) ", _calculated, _actualIndent);
            REPORT_ERROR(ERR_INDENT_UNEXPECTED_NESTED, _forEachIndex, "Unexpected indent for nested item (expected " + str _calculated + ", but actual is " + str _actualIndent + ")");
        };

        if (_indentDiff > 0) then {
            DBG_1("(NESTED) End of the current %1 nested object(s).", _closedCount);
            DBG_2("(NESTED) Going to delete from index %1 (%2)", (count _hashNodesRoute - 1 * _closedCount), _hashNodesRoute select (count _hashNodesRoute - 1 * _closedCount));
            _hashNodesRoute deleteRange [count _hashNodesRoute - 1 * _closedCount, _closedCount];
            DBG_1("(NESTED) Nodes route now: %1", _hashNodesRoute);
        };

        _line = [_line] call CBA_fnc_trim;
        _chars = toArray _line;
        _startsWith = _chars # 0;

        // Array case
        if (_startsWith == ASCII_MINUS) exitWith {
            DBG("(NESTED) Nested element is array item");
            _mode = MODE_NESTED_ARRAY;
            DBG_1("(NESTED) Bookmarking array node %1", _hashNodesRoute);
            if !(IS_IN_ARRAY_NODE) then {
                _arrayNodes pushBackUnique +_hashNodesRoute;
            };
            _self call ["parseLine", []];
        };

        // Object case
        DBG("(NESTED) Nested element is object");
        _mode = MODE_NESTED_OBJECT;
        _self call ["parseLine", []];
    };
    case MODE_NESTED_ARRAY: {
        DBG_1("(NESTED.ARRAY) Line: %1", _line);
        _mode = MODE_NESTED;

        _line = [_line, "- "] call CBA_fnc_leftTrim;

        DBG("(NESTED.ARRAY) Check for oneliner structure");
        private _isOneliner = _self call ["checkIsOneliner", [_line]];
        DBG_1("(NESTED.ARRAY) Is oneliner?: %1", _isOneliner);

        private _parsed = _self call ["parseKeyValuePair", [_line]];
        if (_isOneliner || _parsed isEqualTo []) exitWith {
            DBG("(NESTED.ARRAY) Nested array item case");
            if (IS_MULTILINE_START(_line)) then {
                // Nested Multiline text is found in array
                DBG("(NESTED.ARRAY) #PARSED# Start of the multiline text section. Swtiching to MODE_MULTILINE_TEXT");
                _mode = MODE_MULTILINE_TEXT;
                _self call ["initMultilineBuffer", ["", _actualIndent + INDENT_ARRAY_NESTED, _line]];
            } else {
                // Simple array item: - itemX
                if (IS_IN_ARRAY_NODE) then {
                    _hashNodesRoute deleteAt (count _hashNodesRoute - 1);
                    DBG_1("(NESTED.ARRAY) New array item, step back to array node. Nodes are: %1", _hashNodesRoute);
                };
                private _arrayKey = _self call ["addArrayItem", [_self call ["parseValueType", [_line]]]];
                DBG_1("(NESTED.ARRAY) #PARSED# Simple array item: %1", _arrayKey);
            };
        };

        // Otherwise -- assosiated value or another nested thing: - item: ???
        _parsed params ["_key", "_value"];

        // Nested object: - weapons:
        //                    - some item1
        if (_value isEqualTo "") exitWith {
            DBG("(NESTED.ARRAY.SECTION) Nested section found. Creating array and add subnode to it");

            private _nestedNode = createHashMap;
            private _arrayKey = _self call ["addArrayItem", [_nestedNode]];
            _hashNodesRoute pushBack _arrayKey;

            dzn_SFML call ["addNode", [_key]];
            DBG_1("(NESTED.ARRAY.SECTION) Nested section found. Nodes are: %1", _hashNodesRoute);
        };

        // Array-Nested object found: - item: value
        // ---

        if (IS_IN_ARRAY_NODE) then {
            /* Next array item found:
            - key: value1
                key2: value2
            - key: value3    <--- thsi case - new array item detected
            */
            _hashNodesRoute deleteAt (count _hashNodesRoute - 1);
            DBG_1("(NESTED.ARRAY.OBJECT) New array item, step back to array node. Nodes are: %1", _hashNodesRoute);
        };

        private _nestedNode = createHashMap;
        private _arrayKey = _self call ["addArrayItem", [_nestedNode]];
        _hashNodesRoute pushBack _arrayKey;

        if (IS_MULTILINE_START(_value)) exitWith {
            DBG("(NESTED.ARRAY.OBJECT) #PARSED# Start of the multiline text section. Swtiching to MODE_MULTILINE_TEXT");
            _mode = MODE_MULTILINE_TEXT;
            _self call ["initMultilineBuffer", [_key, _actualIndent + INDENT_ARRAY_NESTED, _value]];
        };

        DBG("(NESTED.ARRAY.OBJECT) #PARSED# Key-value pair found.");
        _self call ["addSetting", [_key, _value]];
    };
    case MODE_NESTED_OBJECT: {
        DBG_1("(NESTED.OBJECT) Line: %1", _line);
        _mode = MODE_NESTED;

        private _parsed = _self call ["parseKeyValuePair", [_line]];
        if (_parsed isEqualTo []) exitWith {
            DBG("(NESTED) [ERROR:ERR_DATA_MALFORMED] Unknown markup in nested line (not a key-value pair/section/array)");
            REPORT_ERROR(ERR_DATA_MALFORMED, _forEachIndex, "Unknown markup in nested line (not a key-value pair/section/array).");
        };

        _parsed params ["_key", "_value"];
        // Item is header of nested
        if (_value == "") exitWith {
            dzn_SFML call ["addNode", [_key]];
            DBG_1("(NESTED.SECTION) #PARSED# This is the header of new nested object: %1", _line);
        };

        // Multiline text is found - add node and switch to multiline mode
        if (IS_MULTILINE_START(_value)) exitWith {
            DBG("(NESTED) #PARSED# Start of the multiline text section. Swtiching to MODE_MULTILINE_TEXT");
            _mode = MODE_MULTILINE_TEXT;
            _self call ["initMultilineBuffer", [_key, _actualIndent, _value]];
        };

        // Item is key-value, just nested:
        DBG_1("(NESTED.SECTION) #PARSED# Nested key-value for node: %1", _hashNodesRoute);
        _self call ["addSetting", [_key, _value]];
    };
};