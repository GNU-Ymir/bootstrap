lexer grammar YmirLexer;

IntegerLiteral:
    DecimalLiteral IntegerSuffix?
    | OctalLiteral IntegerSuffix?
    | HexadecimalLiteral IntegerSuffix? ;

BooleanLiteral: FALSE | TRUE ;

IntNameNoSize:
        'u8'
        | 'i8'
        | 'u16'
        | 'i16'
        | 'u32'
        | 'i32'
        | 'u64'
        | 'i64'
        ;

IntName:
    IntNameNoSize
    | 'usize'
    | 'isize' ;

IntegerSuffix: IntNameNoSize
               | IS
               | 'us' ;

FloatLiteral: DecimalLiteral DOT (DecimalLiteral)? FloatSuffix?
              | DOT DecimalLiteral FloatSuffix?
              ;

FloatSuffix: 'f';

fragment DIGIT: [0-9];
fragment OCTALDIGIT: [0-7];
fragment HEXADECIMALDIGIT: [0-9a-fA-F];

DecimalLiteral : (DIGIT | '_')* DIGIT;
OctalLiteral: '0o' (OCTALDIGIT | '_')* OCTALDIGIT;
HexadecimalLiteral: '0x' (HEXADECIMALDIGIT | '_')* HEXADECIMALDIGIT;

AT: '@';
LBRACK: '{';
RBRACK: '}';
DCOLON: '::';
COLON: ':';
SEMI_COL: ';';
LPAR: '(';
RPAR: ')';
EQUAL: '=';
DIV_EQUAL: '/=';
MINUS_EQUAL: '-=';
ADD_EQUAL: '+=';
STAR_EQUAL: '*=';
MOD_EQUAL: '%=';
TILDE_EQUAL: '~=';
LEFTD_EQUAL: '>>=';
RIGHTD_EQUAL: '<<=';
EXCLAM: '?';
COMA: ',';
DARROW: '=>';
SARROW: '->';
LCRO: '[';
RCRO: ']';
DPIPE: '||';
DAND: '&&';
LT: '<';
GT: '>';
LEQ: '<=';
GEQ: '>=';
DEQUAL: '==';
NOT_EQUAL: '!=';
TDOT: '...';
DDOT: '..';
MINUS: '-';
STAR: '*';
AND: '&';
NOT: '!';
LEFTD: '<<';
RIGHTD: '>>';
PIPE: '|';
XOR: '^';
AND_LCRO: ':[';
DOT: '.';
AND_DOT: ':.';
DOLLAR: '$';

C: 'C';
NEW: 'new';
TYPEID: 'typeid';
SUCCESS: 'success';
FAILURE: 'failure';
EXIT: 'exit';
MAIN: 'main';
UNDER: '_';
SKIPS: 'skips';
MEMBERS: 'members';

AKA: 'aka';
ALIAS: 'alias';
ASSERT: 'assert';
ATOMIC: 'atomic';
BREAK: 'break';
CAST: 'cast';
CLASS: 'class';
TUPLE: 'tuple';
CONST: 'const';
COPY: 'copy';
CTE: 'cte';
DCOPY: 'dcopy';
DEF: 'def';
DG: 'dg';
DMUT: 'dmut';
DO: 'do';
DTOR: '__dtor';
ELSE: 'else';
ENUM: 'enum';
EXPAND: 'expand';
EXTERN: 'extern';
FALSE: 'false';
FOR: 'for';
FN: 'fn';
IF: 'if';
IMPL: 'impl';
IMPORT: 'import';
IN: 'in';
NOT_IN: '!in';
NOT_IS: '!is';
NOT_OF: '!of';
IS: 'is';
LAZY: 'lazy';
LET: 'let';
LOOP: 'loop';
MACRO: 'macro';
MATCH: 'match';
MOD: 'mod';
MUT: 'mut';
NULL: 'null';
OF: 'of';
OVER: 'over';
PRAGMA: '__pragma';
PRV: 'prv';
PROT: 'prot';
PUB: 'pub';
PURE: 'pure';
REF: 'ref';
RETURN: 'return';
SELF: 'self';
SIZEOF: 'sizeof';
STRUCT: 'struct';
SUPER: 'super';
THROW: 'throw';
THROWS: 'throws';
TRAIT: 'trait';
TRUE: 'true';
TYPEOF: 'typeof';
TEST: '__test';
VERSION: '__version';
WHILE: 'while';
WITH: 'with';
ADD: '+';
TILDE: '~';
DIV: '/';
MODULO: '%';
DXOR: '^^';
C8: 'c8';
C32: 'c32';
C16: 'c16';
S8: 's8';
S16: 's16';
S32: 's32';


ID: (UNDER)* [a-zA-Z][a-zA-Z_0-9]* ;
Whitespace: [ \t]+ -> skip;
Newline: ('\r' '\n'? | '\n') -> skip;
BlockComment: '/*' .*? '*/' -> skip;
BlockComment2: '/++' .+? '+/' -> skip;
LineComment: '//' ~ [\r\n]* -> skip;

MacroLiteralC: MACRO_LCRO -> pushMode(MacroLCROCharSet) ;
MacroLiteralB: MACRO_BRACK -> pushMode (MacroBRACKCharSet);
MacroLiteralP: MACRO_PAR -> pushMode (MacroPARCharSet);

StringLiteral: '"' -> pushMode (StringLiteralMode);
CharLiteral: '\'' -> pushMode (CharLiteralMode);

mode StringLiteralMode;
STRING_TEXT: ~["\n\r]+ ;
STRING_LIT_END : '"' -> popMode;

mode CharLiteralMode;
CHAR_TEXT: ~['\n\r]+ ;
CHAR_LIT_END : '\'' -> popMode;

MACRO_LCRO: '#[';
mode MacroLCROCharSet;
MACRO_TEXT_C: ~(']')+ ;
MACRO_RCRO : ']' -> popMode;

MACRO_BRACK: '#{';
mode MacroBRACKCharSet;
MACRO_TEXT_B: ~('}')+ ;
MACRO_RBRACK : '}' -> popMode;

MACRO_PAR: '#(';
mode MacroPARCharSet;
MACRO_TEXT_P: ~(')')+ ;
MACRO_RPAR : ')' -> popMode;
