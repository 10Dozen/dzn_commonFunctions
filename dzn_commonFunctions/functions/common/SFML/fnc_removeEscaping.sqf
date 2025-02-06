#include "defines.h"

/*
    Removes escaping char (backslash \ in front of the escapable char) from the given line

    Params:
    0: _chars (ARRAY) - sequence of chars to process.

    Return: 
	_chars (ARRAY) - modified sequence of chars withour escapings.
*/


// 
params ["_chars"];

if !(ASCII_BACKSLASH in _chars) exitWith { toString _chars };

private _size = count _chars - 2;
private _escapedSymbols = [
    ASCII_ASTERISK, // * - Reference
    ASCII_LT, ASCII_GT, // < > - Variable
    ASCII_SQUARE_BRACKET_OPEN, ASCII_SQUARE_BRACKET_CLOSE, // [ ] - array block
    ASCII_PARENTHESES_OPEN, ASCII_PARENTHESES_CLOSE, // ( ) - hashmap block
    ASCII_CURLY_BRACKET_OPEN, ASCII_CURLY_BRACKET_CLOSE, // { } - Code block
    ASCII_GRAVE, // ` - Expression
    ASCII_VERTICAL_LINE, ASCII_CARET // |, ^ - Multiline block start
];
private _escapingsAt = [];

// Find escpaing symbols (the one that placed in front of escaped symbols)
for "_i" from 0 to _size do {
    private _char = _chars # _i;
    private _nextChar = _chars # (_i + 1);
    if (_char == ASCII_BACKSLASH && { _nextChar in _escapedSymbols }) then {
        DBG_1("(fnc_removeEscaping) Escaping found at %1", _i);
        _escapingsAt pushBack _i;
    };
};

// Remove escaping symbols
reverse _escapingsAt;
{ _chars deleteAt _x; } forEach _escapingsAt;

DBG_1("(fnc_removeEscaping) Result: %1", (toString _chars));
(toString _chars)