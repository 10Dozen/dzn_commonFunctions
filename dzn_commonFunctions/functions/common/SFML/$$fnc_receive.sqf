#include "defines.h"


_chars = [32, 32, 32, 11, 22, 33, 11, 22, 32, 32, 32];

_space = 32;

_leftIdx = _chars findIf { _x != 32};
reverse _chars;
_rightIdx = _chars findIf { _x != 32};

_chars = _chars select [_rightIdx, _leftIdx];
reverse _chars;
_chars


#define TRIM(CHARS_VAR,TRIM_CHAR) \
    private _trim_leftIdx = CHARS_VAR findIf { _x != TRIM_CHAR };
    reverse CHARS_VAR;
    private _trim_rightIdx = CHARS_VAR findIf { _x != TRIM_CHAR };
    CHARS_VAR = CHARS_VAR select [_trim_rightIdx, _trim_leftIdx];
    reverse CHARS_VAR

#define LEFT_TRIM(CHARS_VAR,TRIM_CHAR) \
    private _trim_leftIdx = CHARS_VAR findIf { _x != TRIM_CHAR };
    CHARS_VAR = CHARS_VAR select [_trim_leftIdx, count CHARS_VAR]

#define RIGHT_TRIM(CHARS_VAR,TRIM_CHAR) \
    reverse CHARS_VAR;
    private _trim_rightIdx = CHARS_VAR findIf { _x != TRIM_CHAR };
    CHARS_VAR = CHARS_VAR select [_trim_rightIdx, count CHARS_VAR];
    reverse CHARS_VAR

#define SPLIT_ONCE(CHARS_VAR,SPLIT_CHAR,RESULT_VAR) \
    private _split_leftIdx = CHARS_VAR findIf { _x == SPLIT_CHAT };
    if (_split_leftIdx > -1) then {
        RESULT_VAR = [
            CHARS_VAR select [0, _split_leftIdx],
            CHARS_VAR select [_split_leftIdx, count CHARS_VAR]
        ]
    } else {
        RESULT_AVAR = [CHARS_VAR];
    };