#include "defines.h"

/*
    Parses given file with given mode.

    Params:
	0: _input (STRING) - path to file or sfml string to parse. 
	1: _dataMode (String ENUM) - parsing mode: normal, preprocess or oneliner
	2: _args (ANY) - parsing time arguments.
	3: _convertKeys (BOOL) - flag to parse SFML keys into SQF data types.

    Returns:
    _resultStruct (HashMap) - parsed hash map
*/

params [
	"_input", 
	["_dataMode", MODE_FILE_LOAD],
	["_args", []], 
	["_convertKeys", false]
];

DBG_1("Params: %1", _this);
DBG_1("Mode: %1", _dataMode);

private _startAt = diag_tickTime;
private _printStatistics = true;

private _resultStruct = createHashMap;
_resultStruct set [SOURCE_NODE, _input];
_resultStruct set [ERRORS_NODE, []];

_dataMode = toUpper _dataMode;
private _data = switch _dataMode do {
    case MODE_FILE_LOAD: { loadFile _input };
    case MODE_FILE_PREPROCESS: { preprocessFile _input };
    case MODE_PARSE_LINE: {
        _printStatistics = false;
        if (trim _input == "") then {
            ""
        } else {
            format ["%1: (%2)", DATA_NODE, _input]
        }
    };
    default {
        DBG_1("[ERROR:ERR_MODE_UNDEFINED] Data mode [%1] is unknown!", _dataMode);
        REPORT_ERROR_NOLINE_1(ERR_MODE_UNDEFINED, "Data mode [%1] is unknown!", _dataMode);
        ""
    };
};

DBG_1("Data: %1 chars", count _data);

if (count _data == 0) exitWith {
    REPORT_ERROR_NOLINE(ERR_FILE_EMPTY, 'File is empty!');
    _resultStruct
};

_self set [Q(Struct), _resultStruct];
_self set [Q(DataMode), _dataMode];

forceUnicode 1;


// --- Main programm body
DBG("----------------------------------- PREPARING -----------------------------");
if (_dataMode != MODE_PARSE_LINE) then {
    _self set [Q(StrLines), [_data]];
	_self set [Q(CharsLines), [toArray _data]];
} else {
    _self call [F(splitLines), [_data]]
};
DBG_1("Lines count: %1", count (_self get Q(StrLines)));

private _nonEmptyLinesExists = (_self get Q(CharsLines)) findIf { trim _x != "" } > -1;
DBG_1("Non empty lines found: %1", _nonEmptyLinesExists);

if (!_nonEmptyLinesExists) exitWith {
    DBG("Failed to find non-empty line in the given input.");
    REPORT_ERROR_NOLINE(ERR_FILE_NO_CONTENT, 'File has no content (or commented)!');
    if (_printStatistics) then {
        private _timeSpent = diag_tickTime - _startAt;
        private _errorCount = count (_resultStruct get ERRORS_NODE);
        LOG_3("Parsed file [%1] in %2 seconds. Error count: %3.", _input, _timeSpent, _errorCount);
    };

    _resultStruct
};


DBG("----------------------------------- PARSING -------------------------------");

_lines pushBack EOF;
private _linesCount = count _lines - 1;
private _resultStructNodesRoute = [];
private _arrayNodes = [];
private _hasReferences = false;
private _mode = MODE_ROOT;

{
    private _line = _x;
    private _chars = toArray _line;
    private _startsWith = _chars # 0;
    private _actualIndent = 0;
    for "_i" from 0 to (count _chars)-1 do {
        if (_chars # _i != ASCII_SPACE) exitWith { _actualIndent = _i; };
    };
    DBG_3("Line %1: %2 [Indents: %3]", _forEachIndex+1, _line, _actualIndent);

    if (trim _line isEqualTo "") then {
        if (_mode == MODE_MULTILINE_TEXT) then {
            if (_forEachIndex == _linesCount) exitWith {}; // Last line in file - not a piece of multiline

            private _multilineIndentCount = _resultStruct get MULTILINE_INDENT_NODE;
            DBG("Empty line in multiline mode. Possible newline!");
            if (_actualIndent < _multilineIndentCount) then {
                for "_i" from 1 to _multilineIndentCount do { _chars pushBack ASCII_SPACE };
                _line = toString _chars;
                _actualIndent = _multilineIndentCount;
                DBG_1("Empty line adjusted: [%1]", _line);
            };
        } else {
            DBG_1("Line %1: Is empty. Skipped.", _forEachIndex+1);
            continue;
        };
    };

    _self call ["parseLine", []];
} forEach _lines;

if (_dataMode == MODE_PARSE_LINE) then {
    // Move data from DATA_NODE to main hash, and remove data node
    private _node = _resultStruct get DATA_NODE;
    _resultStruct deleteAt DATA_NODE;
    _resultStruct merge _node;
} else {
    // Trigger conversion to array for last nested array in the file
    _self call [F(convertToArray), []];

    // Link reference values if has any
    if (_hasReferences) then {
        _self call [F(findAndLinkRefValues), []];
    };
};


DBG("----------------------------------- FINISHED -----------------------------");
DBG_1("ResultStruct: %1", _resultStruct);

if (_printStatistics) then {
    private _timeSpent = diag_tickTime - _startAt;
    private _errorCount = count (_resultStruct get ERRORS_NODE);
    LOG_3("Parsed file [%1] in %2 seconds. Error count: %3.", _input, _timeSpent, _errorCount);
};

(_resultStruct)
