#include "script_component.hpp"

/*
Note: On launching by call from consile - nil variable errors are suppressed!
[] spawn { result = [] call compileScript ["tests\SFMLParser\run_tests.sqf"]; }

TODO:
    - Duplicate nodes test
*/

private _path = "tests\SFMLParser";
private _tests = [
    "test_datatypes",
    "test_data_numbers",
    "test_data_sides",
    "test_data_nulls",
    "test_structures1",
    "test_structures2",
    "test_structures3",
    "test_structures4",
    "test_structures5",
    "test_comments",
    "test_references",
    "test_multilines",
    "test_multilines2",
    /* "test_errors"  */
    "test_modes_loadfile",
    "test_modes_preprocessfile",
    "test_modes_parseline",
    "test_parse_line_mode",
    "test_parse_line_mode2",
    "test_empty_input",
    "test_parse_with_arguments"
];

RUN_SUITE
