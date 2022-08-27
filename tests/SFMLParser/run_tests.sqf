#include "script_component.hpp"

/*
call compile preprocessFileLineNumbers "tests\SFMLParser\run_tests.sqf"
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
    /*"test_preprocess_file_mode"*/
    "test_parse_line_mode",
    "test_parse_line_mode2"
];

RUN_SUITE
