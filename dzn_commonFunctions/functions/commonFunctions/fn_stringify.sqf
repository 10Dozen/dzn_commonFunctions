/* 
 *	@StrongResult = @Data call dzn_fnc_stringify;	
 *
 *	Converts input data to string:
 *	"string" 		-> """string"""
 *	{ code } 		-> "code"
 *	[A,r,r,a,y] 		-> "A,r,r,a,y"
 *	5			-> "5"
 *
 *	@WeakResult = [@Data, true] call dzn_fnc_stringify;	
 *
 *	"string" 		-> "string"
 *	{ code } 		-> "code"
 *	[A,r,r,a,y] 		-> "[A,r,r,a,y]"
 *	5			-> "5"
 *
 */
 
 private _result = 0;
 private _isWeak = !(isNil "_this select 0");
 
  if (_isWeak) then {
 	_result = switch (typename (_this select 0)) do {		
		case "CODE";
		case "ARRAY":  { ((str(_this select 0) splitString "") select [1, count str(_this select 0) - 2]) joinString "") };
		default { str(_this select 0) };
	};
 } else {
	_result = switch (typename (_this)) do {
		case "STRING": { _this };
		case "CODE": { ((str(_this) splitString "") select [1, count str(_this) - 2]) joinString "") };
		default { str(_this) };
	};
 };
 
 _result
