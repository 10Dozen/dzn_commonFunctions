#include "defines.h"

/*
    Parses given line according to current mode

    Params:
	0: _chars (ARRAY) - line chars to parse

    Returns:
    nothing
*/
params ["_lineChars", "_actualIndent"];

private _mode = _self get Q(LineMode);
private _currentNodeRoute = _self get Q(CurrentNodesRoute);
if (_mode != MODE_MULTILINE_TEXT && _chars isEqualTo []) exitWith {};


#define CURRENT_NODE_KEY (if (_currentNodeRoute isEqualTo []) then {""} else {_currentNodeRoute select (count _currentNodeRoute - 1)})
#define IS_IN_ARRAY_NODE (CURRENT_NODE_KEY isEqualType 0)

switch _mode do {
    case MODE_ROOT;
    case MODE_NESTED_OBJECT: {
        if (_mode == MODE_ROOT && _actualIndent != 0) exitWith {
            DBG_1("(ROOT) [ERROR:ERR_INDENT_UNEXPECTED_ROOT] Error - unexpected indent: %1", _actualIndent);
            REPORT_ERROR(ERR_INDENT_UNEXPECTED_ROOT, _self get Q(LineNo), "Unexpected indent on parsing root element")
        };

        DBG_1("(ROOT) Line: [%1]", toString _lineChars);
        private _parsed = _self call [F(parseKeyValuePair), [_lineChars]];

        DBG_1("(ROOT) Parsed: %1", _parsed);
        if (_parsed isEqualTo []) exitWith {
            DBG_1("(ROOT) [ERROR:ERR_DATA_MALFORMED] Unknown markup at index: %1", _forEachIndex);
            REPORT_ERROR(ERR_DATA_MALFORMED, _self get Q(LineNo), "Unknown markup in line (not a key-value pair/section/array)");
        };

        _parsed params ["_key", "_value"];

        // Object found (header of nested)
        if (_value isEqualTo []) exitWith {
            _self call [F(addNode), [_key]];
            _self set [Q(LineMode), MODE_NESTED];
            DBG("(ROOT) #PARSED# Is start of the section. Switching to MODE_NESTED");
        };

        // Multiline text is found - add node and switch to multiline mode
        if (IS_MULTILINE_START(_value)) exitWith {
            DBG("(ROOT) #PARSED# Start of the multiline text section. Switching to MODE_MULTILINE_TEXT");
            _self set [Q(LineMode), MODE_MULTILINE_TEXT];
            _self call [F(initMultilineBuffer), [_key, _actualIndent, _value]];
        };

        // Simple key-value pair
        DBG("(ROOT) #PARSED# Adding key-value pair to hash.");
        _self call [F(addSetting), [_key, _value]];
    };
    case MODE_MULTILINE_TEXT: {
        private _expectedIndent = _self get Q(MultilineIndent); //  _hash get MULTILINE_INDENT_NODE;

        // -- End of multiline node
        if (_actualIndent < _expectedIndent) exitWith {
            DBG("(MULTILINE) End of the multiline text.");

            // Saving multiline data

            private _key = _self get Q(MultilineKeyNode); // _hash get MULTILINE_KEY_NODE;
            private _linesList = _self get Q(MultilineValueArray); //_hash get MULTILINE_VALUE_NODE;

            // Clean tailing empty lines
            for "_i" from (count _linesList - 1) to 0 step -1 do {
                if ((_linesList # _i) isEqualTo []) then {
                    _linesList deleteAt _i;
                } else {
                    break;
                };
            };
            // Compose lines according to selected mode
            private _value = switch (_self get Q(MultilineMode)) do {
                case MULTILINE_MODE_NEWLINES: { _linesList joinString endl };
                case MULTILINE_MODE_FOLDED: { _linesList joinString " " };
                case MULTILINE_MODE_CODE: { compile (_linesList joinString endl) };
            };
            DBG_2("(MULTILINE) Key: %1, Composed: %2", _key, _value);

            if (_key isEqualTo "") then {
                // Multiline in array item
                private _arrayKey = _self call [F(addArrayItem), [_value, false]];
                DBG_1("(MULTILINE.ARRAY) Simple array item added with index %1", _arrayKey);
            } else {
                // Multiline in key
                _self call [F(addSetting), [_key, _value, false]];
                DBG_1("(MULTILINE.PAIR) Added to key %1", _key);
            };

            // Drop multiline buffer
            _self set [Q(MultilineKeyNode), nil];
            _self set [Q(MultilineValueArray), nil];
            _self set [Q(MultilineIndent), nil];
            _self set [Q(MultilineMode), nil];

            // Change mode of the parser
            if (_actualIndent == 0) then {
                DBG("(MULTILINE) Returning to MODE_ROOT");
                _currentNodeRoute resize 0;
                // _self set [Q(CurrentNodesRoute), []];
                _self set [Q(LineMode), MODE_ROOT];
            } else {
                DBG("(MULTILINE) Returning to MODE_NESTED");
                _self set [Q(LineMode), MODE_NESTED]
            };

            _self call [F(parseLine), [_lineChars, _actualIndent]];
        };

        // Trim left for a number of the expected indent chars
        private _trimmed = toString (_lineChars select [_expectedIndent, count _lineChars]);
        DBG_1("(MULTILINE) Adding trimmed line [%1] to buffer", toString _trimmed);
        (_self get Q(MultilineValueArray)) pushBack _trimmed;
    };
    case MODE_NESTED: {
        if (_actualIndent == 0) exitWith {
            DBG("(NESTED) End of the all nested objects");
            _currentNodeRoute resize 0;
            // _self set [Q(CurrentNodesRoute), []];
            _self set [Q(LineMode), MODE_ROOT];
            _self call [F(parseLine), [_lineChars, 0]];
        };

        if (_actualIndent % 2 > 0) exitWith {
            DBG_1("(NESTED) [ERROR:ERR_INDENT_MALFORMED] Indent malformed (%1 is not a multiple of 2)", _actualIndent);
            REPORT_ERROR(ERR_INDENT_MALFORMED, _self get Q(LineNo), "Indent malformed (not a multiple of 2)");
        };

        // -- Calculate valid indent
        private _calculated = 0;
        {
            _calculated = _calculated + ([INDENT_DEFAULT, INDENT_ARRAY_NESTED] select (_x isEqualType 0));
        } forEach _currentNodeRoute;
        private _indentDiff = _calculated - _actualIndent;
        private _closedCount = ceil (_indentDiff / INDENT_DEFAULT);
        DBG_2("(NESTED) Calcualted indent: %1 (diff: %2)", _calculated, _indentDiff);

        // -- Undexpected indent 
        if (_indentDiff < 0 || (_indentDiff > 0 && _closedCount == 0)) exitWith {
            DBG_2("(NESTED) [ERROR:ERR_INDENT_UNEXPECTED_NESTED] Unexpected indent for nested item (expected %1, but actual is %2) ", _calculated, _actualIndent);
            REPORT_ERROR(ERR_INDENT_UNEXPECTED_NESTED, _self get Q(LineNo), "Unexpected indent for nested item (expected " + str _calculated + ", but actual is " + str _actualIndent + ")");
        };

        // -- Block ended (indentation shifted left)
        if (_indentDiff > 0) then {
            DBG_1("(NESTED) End of the current %1 nested object(s).", _closedCount);
            DBG_2("(NESTED) Going to delete from index %1 (%2)", (count _currentNodeRoute - 1 * _closedCount), _currentNodeRoute select (count _currentNodeRoute - 1 * _currentNodeRoute));
            _currentNodeRoute deleteRange [count _currentNodeRoute - 1 * _closedCount, _closedCount];
            DBG_1("(NESTED) Nodes route now: %1", _currentNodeRoute);
        };

        TRIM(_lineChars,42);
        _startsWith = _lineChars # 0;

        // Array case
        if (_startsWith == ASCII_MINUS) exitWith {
            DBG("(NESTED) Nested element is array item");
            _self set [Q(LineMode), MODE_NESTED_ARRAY];

            DBG_1("(NESTED) Bookmarking array node %1", _currentNodeRoute);
            if !(IS_IN_ARRAY_NODE) then {
                (_self get Q(ArrayNodes)) pushBackUnique +_currentNodeRoute;
            };

            _self call [F(parseLine), [_lineChars, _actualIndent]];
        };

        // Object case
        DBG("(NESTED) Nested element is object");
        _self set [Q(LineMode), MODE_NESTED_OBJECT];
        _self call [F(parseLine), [_lineChars, _actualIndent]];
    };
    case MODE_NESTED_ARRAY: {
        DBG_1("(NESTED.ARRAY) Line: %1", _line);
        _self set [Q(LineMode), MODE_NESTED];

        if ((_lineChars select [1, 1]) != ASCII_SPACE) exitWith {
            REPORT_ERROR(ERR_DATA_MALFORMED, _self get Q(LineNo), "Unknown markup of array item (should start with '- ')");
        };
        _lineChars = _lineChars select [2, 999];

        DBG("(NESTED.ARRAY) Check for oneliner structure");
        private _isOneliner = _self call [F(checkIsOneliner), [_lineChars]];
        DBG_1("(NESTED.ARRAY) Is oneliner?: %1", _isOneliner);

        private _parsed = _self call [F(parseKeyValuePair), [_lineChars]];

        // -- Array element: `- 23` or `- [1,2,3]`
        if (_isOneliner || _parsed isEqualTo []) exitWith {
            DBG("(NESTED.ARRAY) Nested array item case");
            if (IS_MULTILINE_START(_lineChars)) exitWith {
                // Nested Multiline text is found in array: `- $`
                DBG("(NESTED.ARRAY) #PARSED# Start of the multiline text section. Swtiching to MODE_MULTILINE_TEXT");
                _self set [Q(LineMode), MODE_MULTILINE_TEXT];
                _self call [F(initMultilineBuffer), ["", _actualIndent + INDENT_ARRAY_NESTED, _lineChars]];
            };

            // Simple array item: `- itemX`
            if (IS_IN_ARRAY_NODE) then {
                _currentNodeRoute deleteAt (count _currentNodeRoute - 1);
                DBG_1("(NESTED.ARRAY) New array item, step back to array node. Nodes are: %1", _currentNodeRoute);
            };
            
            // -- Nested array: - - 1
            /*
            if (_lineChars # 0 == ASCII_MINUS) exitWith {
                _self set [Q(LineMode), MODE_NESTED_ARRAY];
                
                private _arrayKey = _self call [F(addArrayItem), []]];
            };
            */
            

            private _arrayKey = _self call [F(addArrayItem), [_lineChars]]];
            DBG_1("(NESTED.ARRAY) #PARSED# Simple array item: %1", _arrayKey);
        };

        // Otherwise -- assosiated value or another nested thing: - item: ???
        _parsed params ["_key", "_value"];

        // Nested object: - weapons:
        //                    - some item1
        if (_value isEqualTo []) exitWith {
            DBG("(NESTED.ARRAY.SECTION) Nested section found. Creating array and add subnode to it");

            private _nestedNode = createHashMap;
            private _arrayKey = _self call [F(addArrayItem), [_nestedNode, false]];
            _currentNodeRoute pushBack _arrayKey;

            _self call [F(addNode), [_key]];
            DBG_1("(NESTED.ARRAY.SECTION) Nested section found. Nodes are: %1", _currentNodeRoute);
        };

        // Array-Nested object found: - item: value
        // ---
        if (IS_IN_ARRAY_NODE) then {
            /* Next array item found:
            - key: value1
                key2: value2
            - key: value3    <--- thsi case - new array item detected
            */
            _currentNodeRoute deleteAt (count _currentNodeRoute - 1);
            DBG_1("(NESTED.ARRAY.OBJECT) New array item, step back to array node. Nodes are: %1", _currentNodeRoute);
        };

        private _nestedNode = createHashMap;
        private _arrayKey = _self call [F(addArrayItem), [_nestedNode, false]];
        _currentNodeRoute pushBack _arrayKey;

        if (IS_MULTILINE_START(_value)) exitWith {
            DBG("(NESTED.ARRAY.OBJECT) #PARSED# Start of the multiline text section. Swtiching to MODE_MULTILINE_TEXT");
            _self set [Q(LineMode), MODE_MULTILINE_TEXT];
            _self call [F(initMultilineBuffer), [_key, _actualIndent + INDENT_ARRAY_NESTED, _value]];
        };

        DBG("(NESTED.ARRAY.OBJECT) #PARSED# Key-value pair found.");
        _self call [F(addSetting), [_key, _value]];
    };
};