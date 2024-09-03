
#define COB dzn_RCE

// Some tackles
#define DEBUG true
#ifdef DEBUG
    #define LOG_PREFIX "(RCE) "
    #define LOG_ diag_log parseText format [LOG_PREFIX +
    #define EOL ]
#else
    #define LOG_PREFIX
    #define LOG_
    #define EOL
#endif

#define Q(X) #X

#define COMPILE_SCRIPT(NAME) compileScript [format ["dzn_commonFunctions\functions\remote\RCE\%1.sqf", Q(NAME)]]
#define PREP_COB_FUNCTION(NAME) [Q(NAME), compileScript [format ["dzn_commonFunctions\functions\remote\RCE\fnc_%1.sqf", Q(NAME)]]]
#define F(NAME) Q(NAME)
#define A(NAME) Q(NAME)

// Attributes
#define L(X) toLowerANSI Q(X)