#include "script_component.hpp"

/*
Note: On launching by call from consile - nil variable errors are suppressed!
[] execVM "tests\SFMLParser\run_tests.sqf"
*/

private _path = "tests\SFMLParser";
private _tests = [
    "test_datatypes",
    "test_data_numbers",
    "test_data_sides",
    "test_data_nulls",
    "test_structure_arrays",
    "test_structure_arrays2",
    "test_structure_hash",
    /* "test_structure_hash2", */
    "test_comments",
    "test_references",
    "test_multilines",
    "test_multilines2",
    /* "test_errors"  */
    "test_modes_loadfile",
    "test_modes_preprocessfile",
    "test_modes_parseline",
    "test_parse_line_mode",
    "test_parse_line_mode2"
];

RUN_SUITE