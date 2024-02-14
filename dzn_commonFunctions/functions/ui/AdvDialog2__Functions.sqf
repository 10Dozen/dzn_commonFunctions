#define ADV_DIALOG2_DEBUG true
#ifdef ADV_DIALOG2_DEBUG
    #define LOG_PREFIX "(AdvDialog2) "
    #define LOG_ diag_log parseText format [LOG_PREFIX +
    #define EOL ]
#else
    #define LOG_PREFIX
    #define LOG_
    #define EOL
#endif


FUNC_COLLECTION = createHashMapFromArray [
    [
        FUNC_OnSliderChanged,
        {
            params ["_ctrl", "_newValue"];
            private _customTooltipText = _ctrl getVariable [P_CONTROL_SLIDER_CUSTOM_TOOLTIP, ""];
            if (_customTooltipText != "") then {
                _customTooltipText = _customTooltipText + "\n";
            };
            private _range = sliderRange _ctrl;

            _ctrl ctrlSetTooltip format [
                "%1%2 (min: %3, max: %4)",
                _customTooltipText,
                _newValue, _range # 0, _range # 1
            ];
        }
    ], [
        FUNC_OnChekboxLabelClicked,
        {
            params ["_control", "_button", "", "", "", "", ""];
            private _cb = _control getVariable P_CONTROL_RELATED_CHECKBOX;
            _cb cbSetChecked !(cbChecked _cb);
        }
    ], [
        FUNC_OnEvent,
        {
            LOG_ "OnEvent: _this=%1", _this EOL;
            params ["_ctrl"];
            private _eventCallback = _ctrl getVariable format ["%1_%2", _thisEvent, A_CALLBACK];
            private _eventCallbackArgs = _ctrl getVariable [
                format ["%1_%2", _thisEvent, A_CALLBACK_ARGS],
                []
            ];

            [
                _this,
                _eventCallbackArgs,
                FUNC_COLLECTION
            ] call _eventCallback;
        }
    ], [
        FUNC_OnButtonClick,
        {
            params ["_control"];
            LOG_ "OnButtonClick: _control=%1, _thisEvene=%2", _control, _thisEvent EOL;
            [
                _control getVariable A_CALLBACK_ARGS,
                FUNC_COLLECTION,
                _control
            ] call (_control getVariable A_CALLBACK);
        }
    ], [
        FUNC_GetValues,
        {
            LOG_ "GetValues: Invoked" EOL;
            private _dialog = findDisplay DIALOG_ID;
            (_dialog getVariable P_DIALOG_INPUTS) apply {
                FUNC_COLLECTION call [FUNC_GetControlValue, _x]
            }
        }
    ], [
        FUNC_GetControlValue,
        {
            // _this - control
            LOG_ "GetControlValue: _this=%1", _this EOL;
            LOG_ "GetControlValue: Control type=%1", _this getVariable A_TYPE EOL;
            private _value = switch (_this getVariable A_TYPE) do {
                case T_INPUT: { ctrlText _this };
                case T_CHECKBOX;
                case T_CHECKBOX_RIGHT: { cbChecked _this };
                case T_SLIDER: { [sliderPosition _this, sliderRange _this] };
                case T_LISTBOX;
                case T_DROPDOWN: {
                    private _selectedIndex = lbCurSel _this;
                    [
                        _selectedIndex,
                        _this lbText _selectedIndex,
                        (_this getVariable A_LIST_VALUES) # _selectedIndex
                    ]
                };
            };

            LOG_ "GetControlValue: Value=%1", _value EOL;
            _value
        }
    ], [
        FUNC_GetByTag,
        {
            // _this - tag name
            LOG_ "GetByTag: _this=%1", _this EOL;
            LOG_ "GetByTag: TaggedItems=%1", ((findDisplay DIALOG_ID) getVariable P_DIALOG_TAGGED) EOL;

            LOG_ "GetByTag: Found Control=%1", ((findDisplay DIALOG_ID) getVariable P_DIALOG_TAGGED) get _this EOL;
            ((findDisplay DIALOG_ID) getVariable P_DIALOG_TAGGED) get _this
        }
    ], [
        FUNC_GetValueByTag,
        {
            // _this - tag name
            LOG_ "GetValueByTag: _this=%1", _this EOL;
            FUNC_COLLECTION call [
                FUNC_GetControlValue,
                FUNC_COLLECTION call [FUNC_GetByTag, _this]
            ]
        }
    ], [
        FUNC_GetTaggedValues, {
            // Returns hash map of Tag-Value pairs
            LOG_ "GetTaggedValues: Invoked"  EOL;
            private _dialog = findDisplay DIALOG_ID;
            private _result = createHashMap;
            {
                private _tag = _x getVariable A_TAG;
                LOG_ "GetTaggedValues: control=%1, tag=%2", _x, _tag EOL;
                _result set [
                    _tag,
                    FUNC_COLLECTION call [FUNC_GetControlValue, _x]
                ];
            } forEach (_dialog getVariable P_DIALOG_INPUTS);

            LOG_ "GetTaggedValues: _result=%1", _result EOL;
            _result
        }
    ]
]
