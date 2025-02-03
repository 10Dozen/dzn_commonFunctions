#include "defines.h"

/*
	Splits input data into array of lines. 
	It also removes comments if present.

	Params:
	0: _data (STRING) - text to split.

	Returns:
	_lines (ARRAY of STRING) - splitted lines.
*/

params ["_data"];

private _chars = toArray _data;
private _isRawFile = _self get Q(DataMode); // _dataMode == MODE_FILE_LOAD;
private _linebreak = [[ASCII_NL], [ASCII_CR, ASCII_NL]] select (ASCII_CR in _chars);
private _linebreakSize = count _linebreak;
_chars append _linebreak;
private _lineChars = [];
private _lines = [];
DBG_1("(splitLines) Linebreaks size: %1", _linebreakSize);

for "_i" from 0 to (count _chars - _linebreakSize) do {
    private _char = _chars # _i;
    private _normalizedLine = "";
    switch _char do {
        case ASCII_CR: {
            if ([_char, _chars # (_i + 1)] isNotEqualTo _linebreak) then { continue; };

            DBG_1("(splitLines) EOL (ASCII_CR, ASCII_NL) detected at position %1", _i);
            _normalizedLine = toString (_self call [F(removeComment), [_lineChars]]);
            _lines pushBack _normalizedLine;
            _lineChars resize 0;
			
            // Skip next char as it expected to be ASCII_NL from [ASCII_CR, ASCII_NL] end of line pair
            _i = _i + 1;
        };
        case ASCII_NL: {
            DBG_1("(splitLines) EOL (ASCII_NL) detected at position %1", _i);
            // Comments are handled differently in LOAD_FILE and PREPROCESS_FILE modes
            _normalizedLine = toString(if (_isRawFile) then {
                _self call [F(removeComment), [_lineChars]]
            } else {
                _lineChars
            });
            _lines pushBack _normalizedLine;
            _lineChars resize 0;
        };
        case ASCII_VERTICAL_LINE: {
			// | in the beginning of the line & file is preprocessed - escape it
            if (_lineChars isEqualTo [] && !_isRawFile) then { continue; };

			_lineChars pushBack _char;
        };
        default {
            _lineChars pushBack _char;
        };
    };

    if (_normalizedLine isNotEqualTo "") then {
        DBG_1("(splitLines) Line found and normalized: %1", _normalizedLine);
    };
};

_lines  