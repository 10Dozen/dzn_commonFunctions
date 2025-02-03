#include "defines.h"

/*
	Removes comments (text after # char) from the line.
	Do nothing if # char is shadowed by \ or / symbol

	Params:
	0: _chars (ARRAY of NUMBERS) - line chars.

	Returns:
	_chars (ARRAY of NUMBERS) - modified input array.
*/

params ["_chars"];

if !(ASCII_HASH in _chars) exitWith { _chars };

private _size = count _chars;
private _commentStartedIndex = -1;
private _escapedHashes = [];
private _inQuotes = false;
private _openQuoteChar = -1;
private _inCode = false;
private _inCodeDepth = 0;
private ["_char"];

DBG_1("(removeComment) Line: %1", toString _chars);

for "_j" from 0 to _size-1 do {
    _char = _chars # _j;

    switch _char do {
		// Handle # (hash) char
        case ASCII_HASH: {
			// Ignore hashes inside the quotes or code
            if (_inQuotes || _inCode) exitWith {				
                DBG_1("(removeComment) Found nested hash at %1. Ignored.", _j);
            }; 
			// Hash on line start
            if (_j == 0) exitWith {
                _commentStartedIndex = _j;
                DBG_1("(removeComment) Found hash at start of the line", _j);
            };
			// Hash escaped with \#
            if (_chars # (_j - 1) == ASCII_BACKSLASH) exitWith {
                _escapedHashes pushBack _j - 1;
                DBG_1("(removeComment) Found escaped hash at : %1", _j - 1);
            };
			_commentStartedIndex = _j;
            DBG_1("(removeComment) Found hash at %1", _j);
        };
		// # in quotes must be ignored - track quotes open/close
        case ASCII_GRAVE;
        case ASCII_QUOTE;
        case ASCII_DOUBLE_QUOTE: {
            if (_inCode) exitWith {}; // Ignore Strings in code
            if (!_inQuotes) exitWith { // Start quotes
                _openQuoteChar = _char;
                _inQuotes = true;
            };
            if (_inQuotes && _char == _openQuoteChar) exitWith { // End quotes
                _openQuoteChar = -1;
                _inQuotes = false;
            };
        };
		// # in brackets should be ignored - track {} brackets open/close (e.g. code mode)
        case ASCII_CURLY_BRACKET_OPEN: {
            if (_inQuotes) exitWith {};
            _inCode = true;
            _inCodeDepth = _inCodeDepth + 1;
        };
        case ASCII_CURLY_BRACKET_CLOSE: {
            if (_inQuotes || !_inCode) exitWith {};
            _inCodeDepth = _inCodeDepth - 1;
            // Close inCode mode
            if (_inCodeDepth == 0) exitWith {
                _inCode = false;
            };
        };
    };

	// Stop seraching and clear comments if unescaped hash was found
    if (_commentStartedIndex > -1) exitWith {
		_chars deleteRange [_commentStartedIndex, _size];
	};
};

// Clear comments
/*
if (_commentStartedIndex > -1) then {
    _chars deleteRange [_commentStartedIndex, _size];
};
*/

// Unwrap escaped hashes: \# -> #
reverse _escapedHashes;
{ _chars deleteAt _x } forEach _escapedHashes;

_chars