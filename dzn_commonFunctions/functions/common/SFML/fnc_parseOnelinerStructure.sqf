#include "defines.h"

/*
	Converts oneliner Array or HashMap into valid Array/Hashmap datatype

	Params:
	0: _oneliner (STRING) - oneliner line.
	1: _mode (NUMBER) - (enum) one of the folowing: ONELINER_ARRAY, ONELINER_HASHMAP (see defines section)

	Returns:
	_onelinerConverted - (Array or HashMap) converted oneliner data structure.
*/

params ["_oneliner", "_mode"];
DBG_2("(parseOnelinerStructure) Oneliner: %1. Mode: %2", _oneliner, _mode);

private _chars = toArray STRIP(_oneliner) + [ASCII_COMMA];
private _lenght = count _chars - 1;
private _onelinerConverted = [];
private _item = [];

private _inQuotes = false;
private _openQuoteChar = -1;

private _inBracket = false;
private _openBracketChar = -1;
private _inBracketsDepth = 0;
private _bracketsOpenCloseMap = createHashMapFromArray [
    [ASCII_PARENTHESES_OPEN, ASCII_PARENTHESES_CLOSE],
    [ASCII_CURLY_BRACKET_OPEN, ASCII_CURLY_BRACKET_CLOSE],
    [ASCII_SQUARE_BRACKET_OPEN, ASCII_SQUARE_BRACKET_CLOSE]
];

for "_i" from 0 to _lenght do {
    private _char = _chars # _i;
    switch _char do {
        // Item separator
        case ASCII_COMMA: {
            if (_inQuotes || _inBracket) exitWith {}; // Ignore comma inside quotes/brackets

            private _itemStr = trim [toString _item];
            DBG_1("(parseOnelinerStructure) Found item: %1", _itemStr);

            switch _mode do {
                case ONELINER_ARRAY: {
                    DBG_1("(parseOnelinerStructure) Converting %1 to ARRAY item", _itemStr);
                    private _value = _self call [F(parseValueType), [_itemStr]];

                    // Make a set, because pushBack ignores 'nil' value (which may be set by user or as result of nil variable reference)
                    _onelinerConverted set [
						count _onelinerConverted,  
						[_value, nil] select (isNil "_value")
					];
                };
                case ONELINER_HASHMAP: {
                    DBG_1("(parseOnelinerStructure) Converting %1 to HASHMAP key-value pair", _itemStr);
                    private _parsed = _self call [F(parseKeyValuePair), [_itemStr]];
                    DBG_1("(parseOnelinerStructure) Parsed key-value: %1", _parsed);

                    if (_parsed isEqualTo []) exitWith {
                        REPORT_ERROR_1(ERR_DATA_KEYVALUEPAIR_MALFORMED, _forEachIndex, "One-liner HashMap pair is malformed", _itemStr);
                    };

                    _parsed params ["_key", "_value"];
                    _value = _self call [F(parseValueType), [_value]];
                    _onelinerConverted pushBack [_key, [_value, nil] select (isNil "_value")];
                };
            };

            _item resize 0;
            _char = nil;
            continue;
        };
        // Quotes
        case ASCII_GRAVE;
        case ASCII_QUOTE;
        case ASCII_DOUBLE_QUOTE: {
            // Drop inQuotes mode if closing quote found
            if (_inQuotes && _char == _openQuoteChar) exitWith {
                DBG_1("(parseOnelinerStructure) [inQuotes] End of quoted sequence at position %1 (exit inQuotes mode).", _i);
                _inQuotes = false;
                _openQuoteChar = -1;
            };
            // Enable inQuotes mode if not yet enabled
            if (!_inQuotes) exitWith {
                DBG_1("(parseOnelinerStructure) [inQuotes] Start of quoted sequence at position %1. (start inQuotes mode)", _i);
                _inQuotes = true;
                _openQuoteChar = _char;
            };
        };
        // Brackets
        case ASCII_PARENTHESES_OPEN;
        case ASCII_CURLY_BRACKET_OPEN;
        case ASCII_SQUARE_BRACKET_OPEN: {
            if (_inQuotes) exitWith {}; // Ignore brackets inside the quotes
            // Another nested structure found - just update depth counter
            if (_inBracket && _char == _openBracketChar) exitWith {
                _inBracketsDepth = _inBracketsDepth + 1;
                DBG_2("(parseOnelinerStructure) [inBracket] Nested brackets start at position %1 (nested level %2).", _i, _inBracketsDepth);
            };
            // First bracket occurance - engage inBracket mode
            if (!_inBracket) exitWith {
                DBG_1("(parseOnelinerStructure) [inBracket] Start of brackets sequence at position %1 (start inBrackets mode)", _i);
                _inBracket = true;
                _inBracketsDepth = _inBracketsDepth + 1;
                _openBracketChar = _char;
            };
        };
        case ASCII_PARENTHESES_CLOSE;
        case ASCII_CURLY_BRACKET_CLOSE;
        case ASCII_SQUARE_BRACKET_CLOSE: {
            if (_inQuotes) exitWith {}; // Ignore closing brackets inside the quotes

            DBG_1("(parseOnelinerStructure) [inBracket] Possible close bracket at pos %1.", _i);
            // In brackets and closing bracket is the same type as open one -- decrease depth
            if (_inBracket && _char == (_bracketsOpenCloseMap get _openBracketChar)) exitWith {
                _inBracketsDepth = _inBracketsDepth - 1;
                DBG_2("(parseOnelinerStructure) [inBracket] End of nested brackets sequence at position %1 (nested level %2).", _i, _inBracketsDepth);
                // If it was the last bracket pair -- exit inBracket mode
                if (_inBracketsDepth == 0) then {
                    _inBracket = false;
                	DBG_1("(parseOnelinerStructure) [inBracket] End of brackets sequence at position %1 (exit inBrackets mode).", _i);
                };
            };
        };
    };

    _item pushBack _char;
};

if (_mode == ONELINER_HASHMAP) then {
    DBG_1("(parseOnelinerStructure) Creating hash map from an array %1", _onelinerConverted);
    _onelinerConverted = createHashMapFromArray _onelinerConverted;
};

(_onelinerConverted)